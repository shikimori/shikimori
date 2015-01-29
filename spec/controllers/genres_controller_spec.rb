describe GenresController do
  let!(:genre) { create :genre }
  before { sign_in create(:user, id: 1) }

  describe '#index' do
    before { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#edit' do
    before { get :edit, id: genre.id }
    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    before { patch :update, id: genre.id, genre: { description: 'new description' } }
    it { expect(response).to redirect_to genres_url }
    it { expect(genre.reload.description).to eq 'new description' }
  end

  describe '#tooltip' do
    before { get :tooltip, id: genre }

    it { expect(response).to have_http_status :success }
  end
end
