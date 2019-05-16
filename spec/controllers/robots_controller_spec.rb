describe RobotsController do
  describe 'anime_online' do
    subject! { get :anime_online }
    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'text/plain'
    end
  end

  describe 'shikimori' do
    subject! { get :shikimori }
    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'text/plain'
    end
  end
end
