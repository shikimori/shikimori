describe Moderations::GenreV2sController do
  include_context :authenticated, :admin
  let!(:genre) { create :genre_v2 }

  describe '#index' do
    subject! { get :index }
    it do
      expect(response).to have_http_status :success
      expect(collection).to have(1).item
    end
  end

  describe '#edit' do
    subject! { get :edit, params: { id: genre.id } }
    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    let(:params) { { description: 'new description' } }
    subject { patch :update, params: { id: genre.id, genre_v2: params } }

    it do
      expect { subject }.to change(Version, :count).by 1
      expect(response).to redirect_to moderations_genre_v2s_url
      expect(resource).to have_attributes params
    end
  end

  describe '#tooltip' do
    subject! { get :tooltip, params: { id: genre } }
    it { expect(response).to have_http_status :success }
  end
end
