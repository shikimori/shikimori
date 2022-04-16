describe Moderations::CollectionsController do
  describe '#index' do
    include_context :authenticated
    let!(:collection) { create :collection, :with_topics }
    subject! { get :index }

    it { expect(response).to have_http_status :success }
  end

  describe '#accept' do
    include_context :authenticated, :collection_moderator
    subject! { post :accept, params: { id: collection.id } }
    let(:collection) { create :collection }

    it do
      expect(resource).to be_moderation_accepted
      expect(response).to redirect_to moderations_collections_url
    end
  end

  describe '#reject' do
    include_context :authenticated, :collection_moderator
    subject! { post :reject, params: { id: collection.id } }
    let(:collection) { create :collection, :with_topics }

    it do
      expect(resource).to be_moderation_rejected
      expect(response).to redirect_to moderations_collections_url
    end
  end

  describe '#cancel' do
    include_context :authenticated, :collection_moderator
    subject! { post :cancel, params: { id: collection.id } }
    let(:collection) { create :collection, :accepted, approver: user }

    it do
      expect(resource).to be_moderation_pending
      expect(response).to redirect_to moderations_collections_url
    end
  end
end
