describe AchievementsController do
  include_context :authenticated, :user

  describe '#index' do
    before { get :index, profile_id: user.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#franchise' do
    before { get :franchise, profile_id: user.to_param }
    it { expect(response).to have_http_status :success }
  end
end
