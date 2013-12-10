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

  describe :complaint do
    before { post :index }
    it { should respond_with_content_type :html }
    it { response.should be_success }
  end
end
