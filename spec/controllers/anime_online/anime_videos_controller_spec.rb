require 'spec_helper'

describe AnimeOnline::AnimeVideosController do
  describe :show do
    context :with_video do
      let(:anime) { create :anime, name: 'anime_test', anime_videos: [create(:anime_video)] }
      before { get :show, id: anime.id }

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
  end

  describe :index do
    before { get :index }
    it { should respond_with_content_type :html }
    it { response.should be_success }
  end

  describe :new do
    let(:anime) { create :anime }
    before { get :new, anime_id: anime.id }
    it { should respond_with_content_type :html }
    it { response.should be_success }
  end

  describe :create do
    let(:anime) { create :anime }
    before { post :create, anime_video: { episode: 1, url: 'http://foo.ru', anime_id: anime.id, source: 'test', kind: 'fandub', author: 'test_author' } }
    it { should respond_with_content_type :html }
    it { response.should be_redirect }
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
end
