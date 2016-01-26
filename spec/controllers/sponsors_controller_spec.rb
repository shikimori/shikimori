describe SponsorsController do
  describe '#adwise_240x400' do
    before { get :adwise_240x400 }
    it { expect(response).to have_http_status :success }
  end
end
