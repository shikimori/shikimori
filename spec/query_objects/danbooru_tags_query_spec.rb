describe DanbooruTagsQuery do
  describe '#complete' do
    let!(:tag_1) { create :danbooru_tag, name: 'ffff' }
    let!(:tag_2) { create :danbooru_tag, name: 'testt' }
    let!(:tag_3) { create :danbooru_tag, name: 'zula zula' }
    let!(:tag_4) { create :danbooru_tag, name: 'test' }

    it do
      expect(DanbooruTagsQuery.new('test').complete).to eq [tag_2, tag_4]
      expect(DanbooruTagsQuery.new('z').complete).to eq [tag_3]
      expect(DanbooruTagsQuery.new('fofo').complete).to eq []
    end
  end
end
