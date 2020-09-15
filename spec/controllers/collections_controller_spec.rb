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
    let(:collection) do
      create :collection, :with_topics,
        kind: Types::Collection::Kind[type],
        user: user
    end
    let(:type) { %i[anime manga ranobe].sample }

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
          links: [link]
        }
      end
      let(:db_entry) { create type }
      let(:link) do
        {
          linked_id: db_entry.id,
          group: 'test',
          text: 'zzzz'
        }
      end

      it do
        expect(resource.reload).to have_attributes name: params[:name]
        expect(resource.links).to have(1).item
        expect(resource.links.first).to have_attributes link
        expect(resource.errors).to be_empty
        expect(response).to redirect_to edit_collection_url(resource)
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
