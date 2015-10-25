describe DashboardsController do
  describe '#show', :focus do
    before { get :show }
    it { expect(response).to have_http_status :success }
  end
end
