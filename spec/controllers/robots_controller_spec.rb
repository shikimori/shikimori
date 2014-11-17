describe RobotsController do
  describe 'anime_online' do
    before { get :anime_online }
    it { should respond_with :success }
    it { should respond_with_content_type :text }
  end

  describe 'manga_online' do
    before { get :manga_online }
    it { should respond_with :success }
    it { should respond_with_content_type :text }
  end

  describe 'shikimori' do
    before { get :shikimori }
    it { should respond_with :success }
    it { should respond_with_content_type :text }
  end
end
