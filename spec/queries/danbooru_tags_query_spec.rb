describe DanbooruTagsQuery do
  describe 'complete' do
    before do
      create :danbooru_tag, name: 'ffff'
      create :danbooru_tag, name: 'testt'
      create :danbooru_tag, name: 'zula zula'
      create :danbooru_tag, name: 'test'
    end

    it { expect(DanbooruTagsQuery.new(search: 'test').complete.size).to eq(2) }
    it { expect(DanbooruTagsQuery.new(search: 'z').complete.size).to eq(1) }
    it { expect(DanbooruTagsQuery.new(search: 'fofo').complete.size).to eq(0) }
  end
end
