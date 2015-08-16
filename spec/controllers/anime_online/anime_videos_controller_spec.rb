describe AnimeOnline::AnimeVideosController, vcr: { cassette_name: 'anime_video_controller' } do
  let(:user) { create :user, :user }
  let(:admin_user) { create :user, :admin }

  let(:anime) { create :anime }

  describe '#index' do
    describe 'video_content' do
      let!(:anime_video) { create :anime_video, anime: anime }
      let(:make_request) { get :index, anime_id: anime.to_param }

      before { allow(AnimeOnlineDomain).to receive(:valid_host?).and_return(true) }
      before { make_request }

      context 'with video' do
        it { expect(response).to have_http_status :success }

        context 'without current_video' do
          let(:make_request) { get :index, anime_id: anime.to_param, episode: anime_video.episode, video_id: anime_video.id + 1 }
          it { expect(response).to have_http_status :success }
        end
      end

      context 'without any video' do
        let!(:anime_video) { }
        it { expect(response).to have_http_status :success }
      end
    end

    describe 'verify adult' do
      let!(:anime) { create :anime }
      let!(:anime_video) { create :anime_video, episode: 1, anime: anime }
      let(:episode) { }
      let(:video_id) { }

      before { allow_any_instance_of(Anime).to receive(:adult?).and_return adult }
      before { @request.host = domain }
      before { get :index, anime_id: anime.to_param, episode: episode, video_id: video_id, domain: 'play' }

      context 'with redirect' do
        let(:episode) { 2 }
        let(:video_id) { anime_video.id }

        context 'adult video' do
          let(:adult) { true }
          let(:domain) { 'play.shikimori.org' }

          it { expect(response).to redirect_to(play_video_online_index_url anime, episode: episode, video_id: video_id, domain: AnimeOnlineDomain::HOST_XPLAY, subdomain: false) }
        end

        context 'adult domain' do
          let(:adult) { false }
          let(:domain) { 'xplay.shikimori.org' }

          it { expect(response).to redirect_to(play_video_online_index_url anime, episode: episode, video_id: video_id, domain: AnimeOnlineDomain::HOST_PLAY, subdomain: false) }
        end
      end

      context 'without redirect' do
        context 'not adult' do
          let(:adult) { false }
          let(:domain) { 'play.shikimori.org' }

          it { expect(response).to have_http_status :success }
        end

        context 'adult' do
          let(:adult) { true }
          let(:domain) { 'xplay.shikimori.org' }

          it { expect(response).to have_http_status :success }
        end
      end
    end
  end

  describe '#new' do
    before { get :new, anime_id: anime.to_param, anime_video: { anime_id: @resource, state: 'uploaded' } }
    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    let!(:guest) { create :user, :guest }
    let(:video_params) {{ state: 'uploaded', kind: kind, author_name: 'test', episode: 3, url: 'https://vk.com/video-16326869_166521208', source: 'test', anime_id: anime.id }}
    let(:continue) { '' }

    let(:created_video) { assigns :video }

    before { post :create, anime_id: anime.to_param, anime_video: video_params, continue: continue }

    context 'valid params' do
      let(:kind) { 'fandub' }

      context 'without continue' do
        it do
          expect(created_video).to be_valid
          expect(created_video).to be_persisted
          expect(created_video).to have_attributes video_params.except(:url)
          expect(created_video.url).to eq VideoExtractor::UrlExtractor.new(video_params[:url]).extract
          expect(response).to redirect_to play_video_online_index_url(anime.id, created_video.episode, created_video.id)
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
            'anime_video[episode]' => video_params[:episode] + 1,
            'anime_video[author_name]' => video_params[:author_name],
          )
        end
      end
    end

    context 'invalid params' do
      let(:kind) { }

      it do
        expect(response).to have_http_status :success
        expect(created_video).to_not be_valid
        expect(created_video).to_not be_persisted
      end
    end
  end

  describe '#edit' do
    include_context :authenticated, :user
    let(:video) { create :anime_video, anime: anime, state: 'uploaded' }
    before { get :edit, anime_id: anime.to_param, id: video.id }

    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    include_context :authenticated, :user

    let(:anime_video) { create :anime_video, anime: anime, state: 'uploaded' }
    let(:video_params) {{ kind: kind, author_name: 'test', episode: 3 }}

    let(:video) { assigns :video }

    before { patch :update,
      anime_id: anime.to_param,
      id: anime_video.id,
      anime_video: video_params,
      reason: 'test'
    }

    context 'valid params' do
      let(:kind) { 'fandub' }
      it do
        expect(video).to be_valid
        expect(video).to have_attributes video_params
        expect(response).to redirect_to play_video_online_index_url(anime.id, video.episode, video.id)
      end
    end

    context 'invalid params' do
      let(:kind) { }

      it do
        expect(response).to have_http_status :success
        expect(video).to_not be_valid
        expect(video).to be_persisted
      end
    end
  end

  describe 'extract_url' do
    let(:url) { 'http://video.rutube.ru/4f4dbbd7882342b057b4c387097e491e' }
    before { post :extract_url, anime_id: anime.id, url: url }

    it do
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#help' do
    before { get :help, anime_id: anime.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#track_view' do
    let(:video) { create :anime_video, watch_view_count: view_count, anime: anime }

    before { post :track_view, anime_id: anime.to_param, id: video.id }
    subject { video.reload.watch_view_count }

    context 'first_time' do
      let(:view_count) { nil }
      it { should eq 1 }
    end

    context 'not_first_time' do
      let(:view_count) { 103 }
      it { should eq view_count + 1 }
    end
  end

  describe '#viewed' do
    include_context :authenticated, :user
    let(:video) { create :anime_video, episode: 10, anime: anime }
    let!(:user_rate) { }

    before { post :viewed, anime_id: anime.to_param, id: video.id }

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
    before { delete :destroy, anime_id: anime.to_param, id: video.id }

    it do
      expect(resource).to be_destroyed
      expect(response).to redirect_to play_video_online_index_url(anime.id, video.episode)
    end
  end
end
