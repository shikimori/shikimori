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
      expect(resource).to_not be_changed
      expect(response).to redirect_to moderations_collections_url
    end
  end

  describe '#reject' do
    include_context :authenticated, :collection_moderator
    subject! { post :reject, params: { id: collection.id } }
    let(:collection) { create :collection, :with_topics }

    it do
      expect(resource).to be_moderation_rejected
      expect(resource).to_not be_changed
      expect(response).to redirect_to moderations_collections_url
    end
  end

  describe '#cancel' do
    include_context :authenticated, :collection_moderator
    subject! { post :cancel, params: { id: collection.id } }
    let(:collection) { create :collection, :accepted, approver: user }

    it do
      expect(resource).to be_moderation_pending
      expect(resource).to_not be_changed
      expect(response).to redirect_to moderations_collections_url
    end
  end

  describe '#autocomplete_user' do
    let(:user) { create :user, nickname: 'user_1' }
    let(:user_2) { create :user, nickname: 'user_2' }
    let!(:collection) { create :collection, :accepted, user: user_2 }

    subject! do
      get :autocomplete_user,
        params: {
          search: 'user_'
        },
        xhr: true,
        format: :json
    end

    it do
      expect(collection).to eq [user_2]
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end
end
