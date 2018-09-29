describe Moderations::UserRateLogsController do
  include_context :authenticated, :user

  describe '#index' do
    let!(:user_rate_log) { create :user_rate_log, user: user }
    subject! { get :index }

    it { expect(response).to have_http_status :success }

    context 'pagination' do
      subject! { get :index, params: { page: 2 }, format: :json }
      it { expect(response).to have_http_status :success }
    end
  end
end
