describe AnimeOnline::AnimeVideosController, :vcr do
  let(:anime) { create :anime }

  describe '#index' do
    describe 'video_content' do
      let!(:anime_video) { create :anime_video, anime: anime }
      let(:make_request) do
        get :index,
          params: { anime_id: anime.to_param },
          xhr: is_xhr
      end
      let(:is_xhr) { false }

      before { allow(AnimeOnlineDomain).to receive(:valid_host?).and_return(true) }
      subject! { make_request }

      context 'with video' do
        it { expect(response).to have_http_status :success }

        context 'xhr' do
          let(:is_xhr) { true }
          it { expect(response).to have_http_status :success }
        end

        context 'without current_video' do
          let(:make_request) do
            get :index,
              params: {
                anime_id: anime.to_param,
                episode: anime_video.episode,
                video_id: anime_video.id + 1
              }
          end
          it { expect(response).to have_http_status :success }
        end
      end

      context 'without any video' do
        let!(:anime_video) {}
        it { expect(response).to have_http_status :success }
      end
    end
  end

  describe '#new' do
    include_context :authenticated, :user, :day_registered
    let(:video_params) { { anime_id: @resource, state: 'uploaded' } }
    subject! do
      get :new,
        params: {
          anime_id: anime.to_param,
          anime_video: video_params
        }
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    include_context :authenticated, :user, :day_registered
    let(:video_params) do
      {
        state: 'uploaded',
        kind: 'fandub',
        author_name: 'test',
        episode: 3,
        url: 'https://vk.com/video-16326869_166521208',
        source: 'test',
        language: 'russian',
        quality: 'bd',
        anime_id: anime_id
      }
    end
    let(:continue) { '' }

    subject! do
      post :create,
        params: {
          anime_id: anime.to_param,
          anime_video: video_params,
          continue: continue
        }
    end
    let(:created_video) { assigns :video }

    context 'valid params' do
      let(:anime_id) { anime.id }

      context 'without continue' do
        it do
          expect(created_video).to be_valid
          expect(created_video).to be_persisted
          expect(created_video).to have_attributes video_params.except(:url)
          expect(created_video.url).to eq Url.new(VideoExtractor::PlayerUrlExtractor.call(video_params[:url])).with_http.to_s
          expect(response).to redirect_to play_video_online_index_url(
            anime, created_video.episode, created_video.id
          )
        end
      end

      context 'with continue' do
        let(:continue) { 'true' }
        it do
          expect(created_video).to be_valid
          expect(created_video).to be_persisted
          expect(response).to redirect_to new_video_online_url(
            'anime_video[anime_id]' => video_params[:anime_id],
            'anime_video[source]' => video_params[:source],
            'anime_video[state]' => video_params[:state],
            'anime_video[kind]' => video_params[:kind],
            'anime_video[language]' => video_params[:language],
            'anime_video[quality]' => video_params[:quality],
            'anime_video[episode]' => video_params[:episode] + 1,
            'anime_video[author_name]' => video_params[:author_name]
          )
        end
      end
    end

    context 'invalid params' do
      let(:anime_id) {}

      it do
        expect(response).to have_http_status :success
        expect(created_video).to_not be_valid
        expect(created_video).to_not be_persisted
      end
    end
  end

  describe '#edit' do
    include_context :authenticated, :user, :day_registered
    let(:video) { create :anime_video, anime: anime, state: 'uploaded' }
    subject! { get :edit, params: { anime_id: anime.to_param, id: video.id } }

    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    let(:anime_video) { create :anime_video, anime: anime, state: 'uploaded' }
    let(:video_params) { { kind: kind, author_name: 'test', episode: 3 } }

    let(:video) { assigns :video }

    let(:make_request) do
      patch :update,
        params: {
          anime_id: anime.to_param,
          id: anime_video.id,
          anime_video: video_params,
          reason: 'test'
        }
    end

    describe 'premoderate' do
      let(:video_versions) { Version.where item: anime_video }
      let(:kind) { 'subtitles' }

      include_context :authenticated, :user, :day_registered
      subject! { make_request }

      it do
        expect(video_versions).to have(1).item
        expect(video).to_not have_attributes video_params
        expect(response).to redirect_to(
          play_video_online_index_url(anime, video.episode, video.id)
        )
      end
    end

    describe 'postmoderate' do
      include_context :authenticated, :video_moderator
      subject! { make_request }

      context 'valid params' do
        let(:kind) { 'fandub' }
        it do
          expect(video).to be_valid
          expect(video).to have_attributes video_params
          expect(response).to redirect_to(
            play_video_online_index_url(anime, video.episode, video.id)
          )
        end
      end

      context 'invalid params' do
        let(:kind) {}

        it do
          expect(response).to have_http_status :success
          expect(video).to_not be_valid
          expect(video).to be_persisted
        end
      end
    end
  end

  describe 'extract_url' do
    let(:url) { 'http://video.rutube.ru/4f4dbbd7882342b057b4c387097e491e' }
    subject! { post :extract_url, params: { anime_id: anime.id, url: url } }

    it do
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#track_view' do
    include_context :authenticated
    let(:video) { create :anime_video, watch_view_count: view_count, anime: anime }

    subject! { post :track_view, params: { anime_id: anime.to_param, id: video.id } }

    context 'first_time' do
      let(:view_count) { nil }
      it { expect(video.reload.watch_view_count).to eq 1 }
    end

    context 'not_first_time' do
      let(:view_count) { 103 }
      it { expect(video.reload.watch_view_count).to eq view_count + 1 }
    end
  end

  describe '#viewed' do
    include_context :authenticated, :user
    let(:video) { create :anime_video, episode: 10, anime: anime }
    let!(:user_rate) {}

    subject! { post :viewed, params: { anime_id: anime.to_param, id: video.id } }

    context 'with user_rate' do
      let!(:user_rate) { create :user_rate, target: anime, user: user, episodes: 1 }
      it do
        expect(assigns(:user_rate).episodes).to eq video.episode
        expect(response).to have_http_status :success
      end
    end

    context 'without user_rate' do
      it do
        expect(assigns(:user_rate).episodes).to eq video.episode
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#destroy' do
    include_context :authenticated, :admin
    let(:video) { create :anime_video, episode: 10, anime: anime }
    subject! { delete :destroy, params: { anime_id: anime.to_param, id: video.id } }

    it do
      expect(resource).to be_destroyed
      expect(response).to redirect_to play_video_online_index_url(
        anime,
        video.episode
      )
    end
  end
end
