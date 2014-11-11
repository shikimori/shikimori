describe MangaOnline::ReadMangaPagesParser do
  before { SiteParserWithCache.stub(:load_cache).and_return entries: {} }
  before { SiteParserWithCache.stub :save_cache }

  let(:chapter) { build :manga_chapter, url: 'http://readmanga.me/berserk/vol36/316?mature=1' }
  let(:parser) { MangaOnline::ReadMangaPagesParser.new chapter }

  describe :pages do
    subject { parser.pages }
    its(:size) { should eq 34 }
    specify { subject.first.url.should eq 'http://y.readmanga.ru/auto/09/26/87/berserk-v36c01p004.jpg' }
  end
end
