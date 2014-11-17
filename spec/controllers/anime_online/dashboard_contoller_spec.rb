describe AnimeOnline::DashboardController do
  let!(:anime) { create :anime, :with_video }

  describe 'show' do
    before { get :show }
    it { should respond_with :success }
  end
end
