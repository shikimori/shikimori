describe BaseMalParser do
  before { allow(SiteParserWithCache).to receive(:load_cache).and_return list: {} }

  let (:parser) {
    p = BaseMalParser.new
    allow(p).to receive(:save_cache)
    p
  }

  describe '#load' do
    let!(:anime_genre) { create :genre, kind: 'anime' }
    let!(:manga_genre) { create :genre, kind: 'manga' }
    let!(:studio) { create :studio }
    let!(:publisher) { create :publisher }

    it do
      expect(parser.genres['anime']).to eq anime_genre.mal_id => anime_genre
      expect(parser.genres['manga']).to eq manga_genre.mal_id => manga_genre
      expect(parser.studios).to eq studio.id => studio
      expect(parser.publishers).to eq publisher.id => publisher
    end
  end

  it 'applies mal_fixes' do
    allow(parser).to receive(:mal_fixes).and_return 1 => {name: 'Test'}
    expect(parser.apply_mal_fixes(1, {entry: {name: 'zzzz'}})[:entry][:name]).to eq 'Test'
  end
end
