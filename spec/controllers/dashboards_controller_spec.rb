describe DashboardsController do
  describe '#show' do
    subject! { get :show }
    it { expect(response).to have_http_status :success }
  end
end
