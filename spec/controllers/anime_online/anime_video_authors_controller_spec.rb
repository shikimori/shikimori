describe AnimeOnline::AnimeVideoAuthorsController do
  describe '#autocomplete' do
    let!(:author_1) { create :anime_video_author, name: 'ffff' }
    let!(:author_2) { create :anime_video_author, name: 'testt' }
    let!(:author_3) { create :anime_video_author, name: 'zula zula' }

    subject! { get :autocomplete, params: { search: 'test' }, xhr: true }
    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
    end
  end
end
