describe Users::ListExportsController do
  include_context :authenticated, :user

  describe '#show' do
    before { get :show }
    it { expect(response).to have_http_status :success }
  end
end
