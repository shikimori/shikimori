describe Users::AchievementsController do
  include_context :authenticated, :user

  describe '#index' do
    let(:user) { create :user, :admin }
    before { get :index, params: { profile_id: user.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#franchise' do
    before { get :franchise, params: { profile_id: user.to_param } }
    it { expect(response).to have_http_status :success }
  end
end
