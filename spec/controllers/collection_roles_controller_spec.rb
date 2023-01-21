describe CollectionRolesController do
  include_context :authenticated, :user, :week_registered
  let(:collection) { create :collection, user: user }

  describe '#create' do
    subject! do
      post :create,
        params: {
          collection_id: collection.id,
          collection_role: {
            collection_id: collection.id,
            user_id: user_2.id
          }
        }
    end

    it do
      expect(resource).to be_persisted
      expect(resource).to_not be_changed
      expect(resource).to have_attributes(
        collection_id: collection.id,
        user_id: user_2.id
      )
      expect(response).to redirect_to edit_collection_url(collection)
    end
  end

  describe '#destroy' do
    let!(:collection_role) do
      create :collection_role, collection: collection, user: user
    end
    subject! do
      post :destroy,
        params: {
          collection_id: collection.id,
          id: collection_role.id
        }
    end

    it do
      expect { resource.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(response).to redirect_to edit_collection_url(collection)
    end
  end
end
