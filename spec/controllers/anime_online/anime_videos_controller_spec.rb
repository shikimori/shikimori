describe AnimeOnline::AnimeVideosController, vcr: { cassette_name: 'anime_video_controller' } do
  let(:user) { create :user, :user }
  let(:admin_user) { create :user, :admin }

  let(:anime) { create :anime }

  describe '#new' do
    before { get :new, anime_id: anime.to_param, anime_video: { anime_id: @resource, state: 'uploaded' } }
    it { expect(response).to have_http_status(:success) }
  end

  describe '#create' do
    before { post :create, anime_id: anime.to_param, anime_video: video_params, continue: continue }
    let(:video_params) {{ state: 'uploaded', kind: kind, author: 'test', episode: 3, url: 'https://vk.com/video-16326869_166521208', source: 'test', anime_id: anime.id }}
    let(:continue) { '' }
    let(:kind) { 'fandub' }

    let(:video) { assigns :video }

    context 'valid params' do
      context 'without continue' do
        it do
          expect(video).to be_valid
          expect(video).to be_persisted
          expect(video).to have_attributes video_params.except(:author, :url)
          expect(video.author.name).to eq video_params[:author]
          expect(video.url).to eq VideoExtractor::UrlExtractor.new(video_params[:url]).extract
          expect(response).to redirect_to play_video_online_index_url(anime.id, video.episode, video.id)
        end
      end

      context 'with continue' do
        let(:continue) { 'true' }
        it do
          expect(assigns :created_video).to be_valid
          expect(assigns :created_video).to be_persisted
          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'invalid params' do
      let(:kind) { }

      it do
        expect(response).to have_http_status(:success)
        expect(video).to_not be_valid
        expect(video).to_not be_persisted
      end
    end
  end

  describe '#index' do
    describe 'video_content' do
      let!(:anime_video) { create :anime_video, anime: anime }

      before { allow(AnimeOnlineDomain).to receive(:valid_host?).and_return(true) }
      before { request }

      context 'with video' do
        let(:request) { get :index, anime_id: anime.to_param }
        it { expect(response).to have_http_status(:success) }

        context 'without current_video' do
          let(:request) { get :index, anime_id: anime.to_param, episode: anime_video.episode, video_id: anime_video.id + 1 }
          it { expect(response).to have_http_status(:success) }
        end
      end

      context 'without any video' do
        let(:anime_video) { }
        it { expect{get :index, anime_id: anime.to_param}.to raise_error(ActionController::RoutingError) }
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

          it { expect(response).to have_http_status(:success) }
        end

        context 'adult' do
          let(:adult) { true }
          let(:domain) { 'xplay.shikimori.org' }

          it { expect(response).to have_http_status(:success) }
        end
      end
    end
  end

  describe 'extract_url' do
    before { post :extract_url, anime_id: anime.id, url: 'http://vk.com/foo' }
    it { expect(response.content_type).to eq 'application/json' }
    it { expect(response).to have_http_status(:success) }
  end

  #describe 'new' do
    #context 'can_new' do
      #let(:anime) { create :anime }
      #before { get :new, anime_id: anime.to_param }
      #it { expect(response).to have_http_status(:success) }
    #end

    #context 'copyright_ban' do
      #let(:anime) { create :anime, id: AnimeVideo::CopyrightBanAnimeIDs.first }
      #it { expect { get :new, anime_id: anime.to_param }.to raise_error(ActionController::RoutingError) }
    #end
  #end

  describe '#create' do
    #before { sign_in user }
    #let(:anime) { create :anime }
    #let(:create_request) { post :create, anime_video: { episode: 1, url: 'http://vk.com/video_ext.php?oid=-11230840&id=164793125&hash=c8f8109b2c0341d7', anime_id: anime.to_param, source: 'test', kind: 'fandub', author: 'test_author' } }

    #context 'response' do
      #before { create_request }
      #it { should respond_with :redirect }
    #end

    #it { expect{create_request}.to change(AnimeVideoReport, :count).by 1 }
  end

  #describe 'destroy' do
    #before { sign_in user }
    #let(:anime_video) { create :anime_video }
    #let!(:anime_video_report) { create :anime_video_report, user: user, anime_video: anime_video }
    #let(:destroy_request) { delete :destroy, id: anime_video.id }

    #context 'response' do
      #before { destroy_request }
      #it { should respond_with :redirect }
    #end

    #it { expect{destroy_request}.to change(AnimeVideoReport, :count).by -1 }
    #it { expect{destroy_request}.to change(AnimeVideo, :count).by -1 }
  #end

  #describe 'help' do
    #before { get :help }
    #it { expect(response).to have_http_status(:success) }
  #end

  #describe 'report' do
    #let!(:moderator) { create :user, id: User::Blackchestnut_ID }
    #let!(:user) { create :user, id: User::GuestID }
    #let!(:anime_video) { create :anime_video }
    #let(:report_request) { post :report, id: anime_video.id, kind: :broken }

    #context 'response' do
      #before { report_request }
      #it { expect(response.content_type).to eq 'text/plain' }
      #it { expect(response).to have_http_status(:success) }
    #end

    #context 'first_request' do
      #it { expect {report_request}.to change(AnimeVideoReport, :count).by 1 }
    #end

    #context 'dublicate_request' do
      #context 'one_user' do
        #context 'same_kind_of' do
          #let!(:report) { create :anime_video_report, anime_video: anime_video, kind: :broken, user: user, state: state }

          #context 'states are equals' do
            #let(:state) { 'pending' }
            #it { expect {report_request}.to change(AnimeVideoReport, :count).by 0 }
          #end

          #context 'states are not equals' do
            #let(:state) { 'rejected' }
            #it { expect {report_request}.to change(AnimeVideoReport, :count).by 1 }
          #end
        #end

        #context 'change report kind if user create new report immediately' do
          #let!(:report) { create :anime_video_report, anime_video: anime_video, kind: :wrong, user: user }
          #it { expect {report_request}.to change(AnimeVideoReport, :count).by 0 }
          #it do
            #report_request
            #expect(AnimeVideoReport.first).to be_broken
          #end
        #end
      #end

      #context 'other_user' do
        #let!(:report) { create :anime_video_report, anime_video: anime_video, kind: :broken }
        #it { expect {report_request}.to change(AnimeVideoReport, :count).by 1 }
      #end
    #end

    #context 'auto_accepted' do
      #before do
        #sign_in user
        #report_request
      #end

      #context 'simple_user' do
        #let(:user) { create :user, id: 777 }
        #specify { expect(AnimeVideoReport.first).to be_pending }
      #end

      #context 'simple_user' do
        #let(:user) { create :user, id: 1 }
        #specify { expect(AnimeVideoReport.first).to be_accepted }
      #end
    #end
  #end

  #describe 'viewed' do
    #let(:anime) { create :anime }
    #let(:video) { create :anime_video }
    #let(:request) { get :viewed, id: video.id, anime_id: anime.to_param }

    #context 'check_response' do
      #before do
        #sign_in user
        #request
      #end

      #it { expect(response).to redirect_to play_video_online_index_url(video.anime_id, video.episode + 1) }
    #end

    #context 'check_user_history' do
      #before { sign_in user }
      #context 'with_rate' do
        #let!(:user_rate) { create :user_rate, :watching, user: user, target: anime }
        #it { expect {request}.to change(UserHistory, :count).by 1 }
      #end

      #context 'without_rate' do
        #it { expect {request}.to change(UserHistory, :count).by 0 }
      #end
    #end
  #end

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
      it { expect(assigns(:user_rate).episodes).to eq video.episode }
      it { expect(response).to have_http_status(:success) }
    end

    context 'without user_rate' do
      it { expect(assigns(:user_rate).episodes).to eq video.episode }
      it { expect(response).to have_http_status(:success) }
    end
  end
end
