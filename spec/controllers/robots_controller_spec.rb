describe RobotsController do
  describe 'anime_online' do
    before { get :anime_online }
    it { expect(response).to have_http_status :success }
    it { expect(response.content_type).to eq 'text/plain' }
  end

  describe 'shikimori' do
    before { get :shikimori }
    it { expect(response).to have_http_status :success }
    it { expect(response.content_type).to eq 'text/plain' }
  end
end
