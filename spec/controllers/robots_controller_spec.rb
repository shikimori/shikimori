describe RobotsController do
  describe 'anime_online' do
    before { get :anime_online }
    it { should respond_with :success }
    it { expect(response.content_type).to eq 'text/plain' }
  end

  describe 'manga_online' do
    before { get :manga_online }
    it { should respond_with :success }
    it { expect(response.content_type).to eq 'text/plain' }
  end

  describe 'shikimori' do
    before { get :shikimori }
    it { should respond_with :success }
    it { expect(response.content_type).to eq 'text/plain' }
  end
end
