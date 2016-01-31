describe SponsorsController do
  describe '#block_1' do
    before { get :block_1 }
    it { expect(response).to have_http_status :success }
  end
end
