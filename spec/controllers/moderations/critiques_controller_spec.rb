describe Moderations::CritiquesController do
  describe '#index' do
    include_context :authenticated
    let!(:critique) { create :critique, :with_topics }
    subject! { get :index }

    it { expect(response).to have_http_status :success }
  end

  describe '#accept' do
    include_context :authenticated, :critique_moderator
    subject! { post :accept, params: { id: critique.id } }
    let(:critique) { create :critique }

    it do
      expect(resource).to be_accepted
      expect(response).to redirect_to moderations_critiques_url
    end
  end

  describe '#reject' do
    include_context :authenticated, :critique_moderator
    subject! { post :reject, params: { id: critique.id } }
    let(:critique) { create :critique, :with_topics }

    it do
      expect(resource).to be_rejected
      expect(response).to redirect_to moderations_critiques_url
    end
  end

  describe '#cancel' do
    include_context :authenticated, :critique_moderator
    subject! { post :cancel, params: { id: critique.id } }
    let(:critique) { create :critique, :accepted, approver: user }

    it do
      expect(resource).to be_pending
      expect(response).to redirect_to moderations_critiques_url
    end
  end
end
