describe AnimeVideoAuthorsQuery do
  describe 'complete' do
    let!(:author_1) { create :anime_video_author, name: 'ffff' }
    let!(:author_2) { create :anime_video_author, name: 'testt' }
    let!(:author_3) { create :anime_video_author, name: 'zula zula' }
    let!(:author_4) { create :anime_video_author, name: 'test' }

    it do
      expect(AnimeVideoAuthorsQuery.new('test').complete).to have(2).items
      expect(AnimeVideoAuthorsQuery.new('est').complete).to have(2).items
      expect(AnimeVideoAuthorsQuery.new('z').complete).to have(1).item
      expect(AnimeVideoAuthorsQuery.new('fofo').complete).to have(0).items
    end
  end
end
