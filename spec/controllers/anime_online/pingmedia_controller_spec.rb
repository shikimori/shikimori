describe AnimeOnline::PingmediaController do
  describe 'google' do
    before { get :google }
    it { should respond_with :success }
  end

  describe 'google_leaderboard' do
    before { get :google_leaderboard }
    it { should respond_with :success }
  end
end
