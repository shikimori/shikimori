require 'spec_helper'

describe MangaPage do
  it { should belong_to :chapter }

  it { should validate_presence_of :url }
  it { should validate_presence_of :number }

  describe :page do
    let(:manga) { build :manga, id: 20 }
    let(:chapter) { build :manga_chapter, id: 10, manga: manga, name: '1 - 1' }
    subject { build :manga_page, chapter: chapter, number: 1 }
    its(:asset_path) { should eq 'images/manga_online/20/1 - 1/1.jpg' }
    its(:path) { should eq '/Users/slash/projects/shikimori.org/shikimori/public/images/manga_online/20/1 - 1/1.jpg' }
    its(:chapter_path) { should eq '/Users/slash/projects/shikimori.org/shikimori/public/images/manga_online/20/1 - 1' }
    its(:manga_path) { should eq '/Users/slash/projects/shikimori.org/shikimori/public/images/manga_online/20' }
  end
end
