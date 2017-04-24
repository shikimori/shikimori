describe CollectionsController do
  include_context :authenticated, :user, :week_registered

  describe '#index' do
    before { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#new' do
    before { get :new, params: { collection: { user_id: user.id } } }
    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    include_context :authenticated, :user, :week_registered

    context 'valid params' do
      before { post :create, params: { collection: params } }
      let(:params) do
        {
          user_id: user.id,
          name: 'test',
          text: '',
          kind: 'anime'
        }
      end

      it do
        expect(resource).to be_persisted
        expect(response).to redirect_to edit_collection_url(resource)
      end
    end

    context 'invalid params' do
      before { post :create, params: { collection: params } }
      let(:params) { { user_id: user.id } }

      it do
        expect(resource).to be_new_record
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#update' do
    include_context :authenticated, :user, :week_registered
    let(:collection) { create :collection, :with_topics, user: user }

    context 'valid params' do
      before do
        patch :update,
          params: {
            id: collection.id,
            collection: params
          }
      end
      let(:params) do
        {
          name: 'test collection',
          linked_ids: [anime.id.to_s],
          linked_groups: ['test']
        }
      end
      let(:anime) { create :anime }

      it do
        expect(resource.reload).to have_attributes name: params[:name]
        expect(resource.links).to have(1).item
        expect(resource.errors).to be_empty
        expect(response).to redirect_to collection_url(resource)
      end
    end

    context 'invalid params' do
      before do
        patch 'update',
          params: {
            id: collection.id,
            collection: params
          }
      end
      let(:params) { { name: '' } }

      it do
        expect(resource.errors).to be_present
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#publish' do
    include_context :authenticated, :user, :week_registered
    let(:collection) { create :collection, :pending, user: user }
    before { post :publish, params: { id: collection.id } }

    it do
      expect(resource.reload).to be_published
      expect(response).to redirect_to edit_collection_url(resource)
    end
  end

  describe '#unpublish' do
    include_context :authenticated, :user, :week_registered
    let(:collection) { create :collection, :published, user: user }
    before { post :unpublish, params: { id: collection.id } }

    it do
      expect(resource.reload).to be_pending
      expect(response).to redirect_to edit_collection_url(resource)
    end
  end

  describe '#destroy' do
    include_context :authenticated, :user, :week_registered
    let(:collection) { create :collection, user: user }
    before { delete :destroy, params: { id: collection.id } }

    it do
      expect { collection.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(response).to redirect_to collections_url
    end
  end
end
