describe DashboardsController do
  describe '#show' do
    subject! { get :show }
    it { expect(response).to have_http_status :success }
  end

  describe '#show_v2' do
    subject! { get :show_v2 }
    it { expect(response).to have_http_status :success }
  end

  describe '#dynamic' do
    subject! { get :dynamic }
    it { expect(response).to have_http_status :success }
  end
end
