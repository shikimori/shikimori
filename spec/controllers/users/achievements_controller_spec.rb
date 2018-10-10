describe Users::AchievementsController do
  include_context :authenticated
  let(:user) { seed :user_admin }

  describe '#index' do
    subject! { get :index, params: { profile_id: user.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#franchise' do
    subject! { get :franchise, params: { profile_id: user.to_param } }
    it { expect(response).to have_http_status :success }
  end
end
