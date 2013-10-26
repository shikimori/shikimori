require 'spec_helper'

describe DanbooruTagsQuery do
  describe 'complete' do
    before do
      create :danbooru_tag, name: 'ffff'
      create :danbooru_tag, name: 'testt'
      create :danbooru_tag, name: 'zula zula'
      create :danbooru_tag, name: 'test'
    end

    it { DanbooruTagsQuery.new(search: 'test').complete.should have(2).items }
    it { DanbooruTagsQuery.new(search: 'z').complete.should have(1).item }
    it { DanbooruTagsQuery.new(search: 'fofo').complete.should have(0).items }
  end
end
