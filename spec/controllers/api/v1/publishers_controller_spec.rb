describe Api::V1::PublishersController, :show_in_doc do
  describe '#show' do
    let!(:publisher) { create :publisher }
    before { get :index, format: :json }

    it { expect(response).to have_http_status :success }
    it { expect(response.content_type).to eq 'application/json' }
  end
end
