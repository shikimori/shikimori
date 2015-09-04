describe Moderations::ReviewsController do
  let(:user) { create :user, id: 1 }
  before { sign_in user }

  describe 'index' do
    before { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe 'accept' do
    let(:review) { create :review, user: user }
    before { post :accept, id: review.id }

    specify { expect(assigns(:review).accepted?).to be_truthy }
    it { expect(response).to redirect_to moderations_reviews_url }
  end

  describe 'reject' do
    let(:review) { create :review, user: user }
    before { post :reject, id: review.id }

    specify { expect(assigns(:review).rejected?).to be_truthy }
    it { expect(response).to redirect_to moderations_reviews_url }
  end
end
