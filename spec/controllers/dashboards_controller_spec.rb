describe DashboardsController do
  describe '#show' do
    before { get :show }
    it { expect(response).to have_http_status :success }
  end
end
