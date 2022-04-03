describe Api::V1::ForumsController, :show_in_doc do
  describe '#index' do
    before { get :index, format: :json }

    it do
      expect(collection).to have_at_least(6).items
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end
end
