describe SponsorsController do
  describe '#show' do
    before { get :show, id: 1 }
    it { expect(response).to have_http_status :success }
  end
end
