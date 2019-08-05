describe DashboardsController do
  describe '#show' do
    subject! { get :show }
    it { expect(response).to have_http_status :success }
  end

  describe '#dynamic' do
    subject! { get :dynamic }
    it { expect(response).to have_http_status :success }
  end
end
