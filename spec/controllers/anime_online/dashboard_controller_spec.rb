describe AnimeOnline::DashboardController do
  let!(:anime) { create :anime, :with_video }

  describe 'show' do
    before { get :show }
    it { expect(response).to have_http_status :success }
  end
end
