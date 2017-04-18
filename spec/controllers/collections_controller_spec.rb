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
        expect(response).to redirect_to collection_url(resource)
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
      let(:params) { { name: 'test collection' } }

      it do
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
end
