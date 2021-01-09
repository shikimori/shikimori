describe CollectionsController do
  include_context :authenticated, :user, :week_registered

  let(:collection) do
    create :collection, :with_topics,
      kind: Types::Collection::Kind[type],
      user: user
  end
  let(:type) { %i[anime manga ranobe].sample }

  describe '#index' do
    subject! { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#new' do
    subject! { get :new, params: { collection: { user_id: user.id } } }
    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    context 'valid params' do
      subject! { post :create, params: { collection: params } }
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
      subject! { post :create, params: { collection: params } }
      let(:params) { { user_id: user.id } }

      it do
        expect(resource).to be_new_record
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#update' do
    context 'valid params' do
      subject! do
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
      subject! do
        patch 'update', params: { id: collection.id, collection: params }
      end
      let(:params) { { name: '' } }

      it do
        expect(resource.errors).to be_present
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#to_published' do
    subject! { post :to_published, params: { id: collection.id } }

    it do
      expect(resource.reload).to be_published
      expect(resource.errors).to be_empty
      expect(response).to redirect_to edit_collection_url(resource)
    end
  end

  describe '#to_private' do
    subject! { post :to_private, params: { id: collection.id } }

    it do
      expect(resource.reload).to be_private
      expect(resource.errors).to be_empty
      expect(response).to redirect_to edit_collection_url(resource)
    end
  end

  describe '#to_hidden' do
    subject! { post :to_hidden, params: { id: collection.id } }

    it do
      expect(resource.reload).to be_hidden
      expect(resource.errors).to be_empty
      expect(response).to redirect_to edit_collection_url(resource)
    end
  end

  describe '#destroy' do
    let(:collection) { create :collection, user: user }
    before { delete :destroy, params: { id: collection.id } }

    it do
      expect { collection.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(response).to redirect_to collections_url
    end
  end

  describe '#autocomplete' do
    let(:phrase) { 'Fff' }
    let(:collection_1) { create :collection, :published }
    let(:collection_2) { create :collection, :published }

    before do
      allow(Elasticsearch::Query::Collection).to receive(:call).with(
        locale: :ru,
        phrase: phrase,
        limit: Collections::Query::SEARCH_LIMIT
      ).and_return(
        collection_1.id => 987,
        collection_2.id => 654
      )
    end
    subject! { get :autocomplete, params: { search: phrase }, xhr: true }

    it do
      expect(assigns(:collection)).to eq [collection_2, collection_1]
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end
end
