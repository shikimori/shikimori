describe Api::V1::StudiosController, :show_in_doc do
  describe '#show' do
    let!(:studio) { create :studio }
    before { get :index, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end
end
