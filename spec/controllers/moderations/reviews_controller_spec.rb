describe Moderations::ReviewsController do
  include_context :authenticated, :review_moderator

  describe 'index' do
    before { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe 'accept' do
    let(:review) { create :review, user: user }
    before { post :accept, params: { id: review.id } }

    it do
      expect(assigns(:review).accepted?).to eq true
      expect(response).to redirect_to moderations_reviews_url
    end
  end

  describe 'reject' do
    let(:review) { create :review, :with_topics, user: user }
    before { post :reject, params: { id: review.id } }

    it do
      expect(assigns(:review).rejected?).to eq true
      expect(response).to redirect_to moderations_reviews_url
    end
  end
end
