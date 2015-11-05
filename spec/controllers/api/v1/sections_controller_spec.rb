describe Api::V1::SectionsController, :show_in_doc do
  describe '#index' do
    before { get :index, format: :json }

    it do
      expect(collection).to have(6).items
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end
end
