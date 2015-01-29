describe AnimeOnline::PingmediaController do
  describe 'google' do
    before { get :google }
    it { expect(response).to have_http_status :success }
  end

  describe 'google_leaderboard' do
    before { get :google_leaderboard }
    it { expect(response).to have_http_status :success }
  end
end
