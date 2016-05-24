describe AnimeOnline::AnimeVideoAuthorsController do
  describe '#autocomplete' do
    let!(:author_1) { create :anime_video_author, name: 'ffff' }
    let!(:author_2) { create :anime_video_author, name: 'testt' }
    let!(:author_3) { create :anime_video_author, name: 'zula zula' }

    before { get :autocomplete, search: 'test' }
    it do
      expect(collection).to have(1).item
      expect(response).to be_success
    end
  end
end
