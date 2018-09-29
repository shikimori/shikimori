describe Moderations::UserRateLogsController do
  include_context :authenticated, :user
  let!(:user_rate_log) { create :user_rate_log, user: user }

  describe '#index' do
    subject! { get :index }
    it { expect(response).to have_http_status :success }

    context 'pagination' do
      subject! { get :index, params: { page: 2 }, format: :json }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#show' do
    subject! { get :show, params: { id: user_rate_log.id } }
    it { expect(response).to have_http_status :success }
  end
end
