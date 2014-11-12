describe Moderation::ReviewsController, :type => :controller do
  let(:user) { create :user, id: 1 }
  before { sign_in user }

  describe 'index' do
    before { get :index }

    it { should respond_with :success }
    it { should respond_with_content_type :html }
  end

  describe 'accept' do
    let(:review) { create :review, user: user }
    before { post :accept, id: review.id }

    specify { expect(assigns(:review).accepted?).to be_truthy }
    it { should redirect_to moderation_reviews_url }
  end

  describe 'reject' do
    let(:review) { create :review, user: user }
    before { post :reject, id: review.id }

    specify { expect(assigns(:review).rejected?).to be_truthy }
    it { should redirect_to moderation_reviews_url }
  end
end
