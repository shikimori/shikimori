describe Api::V1::SectionsController do
  describe '#index' do
    let!(:section) { create :section }

    before { get :index, format: :json }

    it { expect(response).to have_http_status :success }
    it { expect(response.content_type).to eq 'application/json' }
  end
end
