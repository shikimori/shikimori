describe Api::V1::GenresController do
  describe '#show' do
    let!(:genre) { create :genre }
    before { get :index, format: :json }

    it { expect(response).to have_http_status :success }
    it { expect(response.content_type).to eq 'application/json' }
  end
end
