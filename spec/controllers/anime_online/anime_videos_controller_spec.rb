describe AnimeOnline::AnimeVideosController do
  let(:user) { create :user, :user }
  let(:admin_user) { create :user, :admin }

  describe '#index' do
    describe 'video_content' do
      let(:anime) { create :anime, name: 'anime_test' }
      let!(:anime_video) { create :anime_video, anime: anime }

      before { allow(AnimeOnlineDomain).to receive(:valid_host?).and_return(true) }
      before { request }

      context 'with_video' do
        let(:request) { get :index, anime_id: anime.to_param }
        it { should respond_with :success }

        context 'without_current_video' do
          let(:request) { get :index, anime_id: anime.to_param, episode: anime_video.episode, video_id: anime_video.id + 1 }
          it { should respond_with :success }
        end
      end

      context 'without_any_video' do
        let(:anime) { create :anime, name: 'anime_test' }
        it { expect{get :index, anime_id: anime.to_param}.to raise_error(ActionController::RoutingError) }
      end
    end

    describe 'verify_adult' do
      before { allow_any_instance_of(Anime).to receive(:adult?).and_return adult }
      before { @request.host = domain }
      before { get :index, anime_id: anime.to_param, episode: episode, video_id: video_id, domain: 'play' }

      let(:anime) { create :anime, anime_videos: [] }
      let(:anime_video) { create :anime_video, episode: 1, anime: anime }

      let(:episode) { }
      let(:video_id) { }

      context 'with_redirect' do
        let(:episode) { 2 }
        let(:video_id) { anime_video.id }

        context 'adult_video' do
          let(:adult) { true }
          let(:domain) { 'play.shikimori.org' }

          it { should redirect_to(play_video_online_index_url anime, episode: episode, video_id: video_id, domain: AnimeOnlineDomain::HOST_XPLAY, subdomain: false) }
        end

        context 'adult_domain' do
          let(:adult) { false }
          let(:domain) { 'xplay.shikimori.org' }

          it { should redirect_to(play_video_online_index_url anime, episode: episode, video_id: video_id, domain: AnimeOnlineDomain::HOST_PLAY, subdomain: false) }
        end
      end

      context 'without_redirect' do
        context 'not_adult' do
          let(:adult) { false }
          let(:domain) { 'play.shikimori.org' }

          it { should respond_with :success }
        end

        context 'adult' do
          let(:adult) { true }
          let(:domain) { 'xplay.shikimori.org' }

          it { should respond_with :success }
        end
      end
    end
  end

  #describe 'new' do
    #context 'can_new' do
      #let(:anime) { create :anime }
      #before { get :new, anime_id: anime.to_param }
      #it { should respond_with :success }
    #end

    #context 'copyright_ban' do
      #let(:anime) { create :anime, id: AnimeVideo::CopyrightBanAnimeIDs.first }
      #it { expect { get :new, anime_id: anime.to_param }.to raise_error(ActionController::RoutingError) }
    #end
  #end

  #describe 'create' do
    #before { sign_in user }
    #let(:anime) { create :anime }
    #let(:create_request) { post :create, anime_video: { episode: 1, url: 'http://vk.com/video_ext.php?oid=-11230840&id=164793125&hash=c8f8109b2c0341d7', anime_id: anime.to_param, source: 'test', kind: 'fandub', author: 'test_author' } }

    #context 'response' do
      #before { create_request }
      #it { should respond_with :redirect }
    #end

    #it { expect{create_request}.to change(AnimeVideoReport, :count).by 1 }
  #end

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
    #it { should respond_with :success }
  #end

  #describe 'report' do
    #let!(:moderator) { create :user, id: User::Blackchestnut_ID }
    #let!(:user) { create :user, id: User::GuestID }
    #let!(:anime_video) { create :anime_video }
    #let(:report_request) { post :report, id: anime_video.id, kind: :broken }

    #context 'response' do
      #before { report_request }
      #it { expect(response.content_type).to eq 'text/plain' }
      #it { should respond_with :success }
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

  #describe 'extract_url' do
    #before { post :extract_url, url: 'http://vk.com/foo' }
    #it { expect(response.content_type).to eq 'text/plain' }
    #it { should respond_with :success }
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

      #it { should redirect_to play_video_online_index_url(video.anime_id, video.episode + 1) }
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
    subject { video.reload.watch_view_count }
    let(:anime) { create :anime }
    let(:video) { create :anime_video, watch_view_count: view_count, anime: anime }

    before { post :track_view, anime_id: anime.to_param, id: video.id }

    context 'first_time' do
      let(:view_count) { nil }
      it { should eq 1 }
    end

    context 'not_first_time' do
      let(:view_count) { 103 }
      it { should eq view_count + 1 }
    end
  end
end
