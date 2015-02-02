describe MangaOnline::ReadMangaChaptersParser, vcr: { cassette_name: 'read_manga_chapters_parser' } do
  before { allow(SiteParserWithCache).to receive(:load_cache).and_return entries: {} }

  let(:manga) { create :manga, name: 'Berserk', read_manga_id: 'rm_berserk' }
  let(:chapters_path) { '/berserk/vol36/316?mature=1' }
  let(:parser) { MangaOnline::ReadMangaChaptersParser.new manga.id, chapters_path }

  describe 'chapters' do
    subject { parser.chapters }
    its(:size) { should eq 22 }
  end
end
