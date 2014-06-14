require 'spec_helper'

describe MangaOnline::ReadMangaChaptersParser do
  before { SiteParserWithCache.stub(:load_cache).and_return entries: {} }
  before { SiteParserWithCache.stub :save_cache }

  let(:manga) { create :manga, name: 'Berserk', read_manga_id: 'rm_berserk' }
  let(:chapters_path) { '/berserk/vol2/5?mature=1' }
  let(:parser) { MangaOnline::ReadMangaChaptersParser.new manga.id, chapters_path }

  describe :chapters do
    subject { parser.chapters }
    its(:size) { should eq 21 }
  end
end
