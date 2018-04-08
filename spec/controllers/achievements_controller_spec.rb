describe AchievementsController do
  include_context :authenticated, :user

  describe '#index' do
    before { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#group' do
    before { get :group, params: { group: 'common' } }
    it { expect(response).to have_http_status :success }
  end

  describe '#show' do
    before { get :show, params: { group: 'common', id: 'animelist' } }
    it { expect(response).to have_http_status :success }
  end
end
