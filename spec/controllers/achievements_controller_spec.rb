describe AchievementsController do
  include_context :authenticated, :user

  describe '#index' do
    before { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#group' do
    context 'group' do
      before { get :group, params: { group: 'common' } }
      it { expect(response).to have_http_status :success }
    end

    context 'neko_id' do
      before { get :group, params: { group: 'animelist' } }
      it { expect(response).to redirect_to achievement_url('common', 'animelist') }
    end
  end

  describe '#show' do
    before { get :show, params: { group: 'common', id: 'animelist' } }
    it { expect(response).to have_http_status :success }
  end

  describe '#users' do
    before { get :users, params: { group: 'common', id: 'animelist', level: 1 } }
    it { expect(response).to have_http_status :success }
  end
end
