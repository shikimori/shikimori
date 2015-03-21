describe Api::V1::AuthenticityTokensController, :show_in_doc do
  describe '#show' do
    before { get :show }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end
end
