describe MangaOnline::ReadMangaPagesParser do
  before { allow(SiteParserWithCache).to receive(:load_cache).and_return entries: {} }
  before { allow(SiteParserWithCache).to receive :save_cache }

  let(:chapter) { build :manga_chapter, url: 'http://readmanga.me/berserk/vol36/316?mature=1' }
  let(:parser) { MangaOnline::ReadMangaPagesParser.new chapter }

  describe 'pages' do
    subject { parser.pages }
    its(:size) { should eq 34 }
    specify { expect(subject.first.url).to eq 'http://y.readmanga.ru/auto/09/26/87/berserk-v36c01p004.jpg' }
  end
end
