describe MangaOnline::ReadMangaChaptersParser do
  before { allow(SiteParserWithCache).to receive(:load_cache).and_return entries: {} }
  before { allow(SiteParserWithCache).to receive :save_cache }

  let(:manga) { create :manga, name: 'Berserk', read_manga_id: 'rm_berserk' }
  let(:chapters_path) { '/berserk/vol2/5?mature=1' }
  let(:parser) { MangaOnline::ReadMangaChaptersParser.new manga.id, chapters_path }

  describe 'chapters' do
    subject { parser.chapters }
    its(:size) { should eq 21 }
  end
end
