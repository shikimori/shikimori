describe Moderations::GenresController do
  include_context :authenticated, :admin
  let!(:genre) { create :genre }

  describe '#index' do
    before { get :index }
    it do
      expect(response).to have_http_status :success
      expect(collection).to have(1).item
    end
  end

  describe '#edit' do
    before { get :edit, params: { id: genre.id } }
    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    let(:params) { { description: 'new description' } }
    before { patch :update, params: { id: genre.id, genre: params } }

    it do
      expect(response).to redirect_to moderations_genres_url
      expect(resource).to have_attributes params
    end
  end

  describe '#tooltip' do
    before { get :tooltip, params: { id: genre } }
    it { expect(response).to have_http_status :success }
  end
end
