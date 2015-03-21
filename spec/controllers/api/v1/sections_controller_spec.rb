describe Api::V1::SectionsController, :show_in_doc do
  describe '#index' do
    let!(:section) { create :section }

    before { get :index, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end
end
