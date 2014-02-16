require 'spec_helper'

describe AnimeOnline::AnimeVideosController do
  describe :show do
    context :with_video do
      let(:anime) { create :anime, name: 'anime_test', anime_videos: [create(:anime_video)] }
      before do
        @request.host = 'play.test'
        get :show, id: anime.id
      end

      it { should respond_with_content_type :html }
      it { response.should be_success }

      describe :search do
        before { get :show, id: anime.id, search: 'foo' }
        it { should respond_with_content_type :html }
        it { should redirect_to(anime_videos_url search: 'foo') }
      end
    end

    context :without_video do
      let(:anime) { create :anime, name: 'anime_test' }
      it { expect { get :show, id: anime.id }.to raise_error(ActionController::RoutingError) }
    end

    describe :verify_adult do
      before do
        Anime.any_instance.stub(:adult?).and_return adult
        @request.host = domain
        get :show, id: anime.id, domain: 'play'
      end
      let(:anime) { create :anime, anime_videos: [create(:anime_video)] }

      context :with_redirect do
        context :adult_video do
          let(:adult) { true }
          let(:domain) { 'play.shikimori.org' }

          it { should respond_with_content_type :html }
          it { should redirect_to(anime_videos_show_url anime.id, domain: AnimeOnlineDomain::HOST_XPLAY, subdomain: false) }
        end

        context :adult_domain do
          let(:adult) { false }
          let(:domain) { 'xplay.shikimori.org' }

          it { should respond_with_content_type :html }
          it { should redirect_to(anime_videos_show_url anime.id, domain: AnimeOnlineDomain::HOST_PLAY, subdomain: false) }
        end
      end

      context :without_redirect do
        context :not_adult do
          let(:adult) { false }
          let(:domain) { 'play.shikimori.org' }

          it { should respond_with_content_type :html }
          it { response.should be_success }
        end

        context :adult do
          let(:adult) { true }
          let(:domain) { 'xplay.shikimori.org' }

          it { should respond_with_content_type :html }
          it { response.should be_success }
        end
      end
    end
  end

  describe :index do
    context :admin do
      before do
        sign_in create :user, id: 1
        get :index
      end
      it { should respond_with_content_type :html }
      it { response.should be_success }
    end

    context :user do
      before do
        sign_in create :user, id: 2
        get :index
      end
      it { should respond_with_content_type :html }
      it { response.should be_success }
    end

    context :guest do
      before { get :index }
      it { should respond_with_content_type :html }
      it { response.should be_success }
    end
  end

  describe :search do
    before { post :search, search: 'test' }
    it { should respond_with_content_type :html }
    it { response.should be_redirect }
  end

  describe :new do
    context :can_new do
      let(:anime) { create :anime }
      before { get :new, anime_id: anime.id }
      it { should respond_with_content_type :html }
      it { response.should be_success }
    end

    context :copyright_ban do
      let(:anime) { create :anime, id: AnimeVideo::CopyrightBanAnimeIDs.first }
      it { expect { get :new, anime_id: anime.id }.to raise_error(ActionController::RoutingError) }
    end
  end

  describe :create do
    before { sign_in user }
    let(:user) { create :user }
    let(:anime) { create :anime }
    let(:create_request) { post :create, anime_video: { episode: 1, url: 'http://foo.ru', anime_id: anime.id, source: 'test', kind: 'fandub', author: 'test_author' } }

    context :response do
      before { create_request }
      it { should respond_with_content_type :html }
      it { response.should be_redirect }
    end

    it { expect{create_request}.to change(AnimeVideoReport, :count).by 1 }
  end

  describe :destroy do
    before { sign_in user }
    let(:user) { create :user }
    let(:anime_video) { create :anime_video }
    let!(:anime_video_report) { create :anime_video_report, user: user, anime_video: anime_video }
    let(:destroy_request) { delete :destroy, id: anime_video.id }

    context :response do
      before { destroy_request }
      it { should respond_with_content_type :html }
      it { response.should be_redirect }
    end

    it { expect{destroy_request}.to change(AnimeVideoReport, :count).by -1 }
    it { expect{destroy_request}.to change(AnimeVideo, :count).by -1 }
  end

  describe :help do
    before { get :help }
    it { should respond_with_content_type :html }
    it { response.should be_success }
  end

  describe :report do
    let!(:moderator) { create :user, id: User::Blackchestnut_ID }
    let!(:user) { create :user, id: User::GuestID }
    let!(:anime_video) { create :anime_video }
    let(:report_repuest) { post :report, id: anime_video.id, kind: :broken }

    context :response do
      before { report_repuest }
      it { should respond_with_content_type :html }
      it { response.should be_success }
    end

    context :first_request do
      it { expect {report_repuest}.to change(AnimeVideoReport, :count).by 1 }
    end

    context :not_dublicate_request do
      let!(:report) { create :anime_video_report, anime_video: anime_video, kind: :broken }
      it { expect {report_repuest}.to change(AnimeVideoReport, :count).by 0 }
    end
  end

  describe :extracted_url do
    before { post :extract_url, url: 'http://vk.com/foo' }
    it { should respond_with_content_type :html }
    it { response.should be_success }
  end
end
