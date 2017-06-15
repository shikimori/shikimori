describe Moderations::CollectionsController do
  let(:user) { create :user, id: 1 }
  before { sign_in user }

  describe 'index' do
    before { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe 'accept' do
    let(:collection) { create :collection, user: user }
    before { post :accept, params: { id: collection.id } }

    it do
      expect(assigns(:collection).accepted?).to eq true
      expect(response).to redirect_to moderations_collections_url
    end
  end

  describe 'reject' do
    let(:collection) { create :collection, :with_topics, user: user }
    before { post :reject, params: { id: collection.id } }

    it do
      expect(assigns(:collection).rejected?).to eq true
      expect(response).to redirect_to moderations_collections_url
    end
  end
end
