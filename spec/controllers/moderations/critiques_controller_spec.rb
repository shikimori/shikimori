describe Moderations::CritiquesController do
  describe '#index' do
    include_context :authenticated
    let!(:review) { create :review, :with_topics }
    subject! { get :index }

    it { expect(response).to have_http_status :success }
  end

  describe '#accept' do
    include_context :authenticated, :critique_moderator
    subject! { post :accept, params: { id: review.id } }
    let(:review) { create :review }

    it do
      expect(resource).to be_accepted
      expect(response).to redirect_to moderations_reviews_url
    end
  end

  describe '#reject' do
    include_context :authenticated, :critique_moderator
    subject! { post :reject, params: { id: review.id } }
    let(:review) { create :review, :with_topics }

    it do
      expect(resource).to be_rejected
      expect(response).to redirect_to moderations_reviews_url
    end
  end

  describe '#cancel' do
    include_context :authenticated, :critique_moderator
    subject! { post :cancel, params: { id: review.id } }
    let(:review) { create :review, :accepted, approver: user }

    it do
      expect(resource).to be_pending
      expect(response).to redirect_to moderations_reviews_url
    end
  end
end
