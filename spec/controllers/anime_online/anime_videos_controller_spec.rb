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

  describe :complaint do
    let!(:moderator) { create :user, id: User::Blackchestnut_ID }
    let!(:user) { create :user, id: User::GuestID }
    let!(:anime) { create :anime, name: 'anime_test' }
    before { post :complaint, id: anime.id, episode_id: 1, video_id: 1, kind: :broken_video }
    it { should respond_with_content_type :html }
    it { response.should be_success }
  end
end
