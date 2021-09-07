describe DashboardsController do
  describe '#show' do
    context 'new' do
      include_context :authenticated
      before { user.preferences.update! dashboard_type: :new }
      subject! { get :show }
      it { expect(response).to have_http_status :success }
    end

    context 'old' do
      subject! { get :show }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#dynamic' do
    subject! { get :dynamic }
    it { expect(response).to have_http_status :success }
  end

  describe '#data_deletion' do
    subject! { get :data_deletion }
    it { expect(response).to have_http_status :success }
  end
end
