describe BaseMalParser do
  before { allow(SiteParserWithCache).to receive(:load_cache).and_return list: {} }

  let (:parser) {
    p = BaseMalParser.new
    allow(p).to receive(:save_cache)
    p
  }

  describe 'load' do
    it 'genres' do
      genre = FactoryGirl.create :genre
      expect(parser.genres.size).to eq(1)
      expect(parser.genres[genre.id].name).to eq genre.name
    end

    it 'studios' do
      studio = FactoryGirl.create :studio
      expect(parser.studios.size).to eq(1)
      expect(parser.studios[studio.id].name).to eq studio.name
    end

    it 'publishers' do
      publisher = FactoryGirl.create :publisher
      expect(parser.publishers.size).to eq(1)
      expect(parser.publishers[publisher.id].name).to eq publisher.name
    end
  end

  it 'applies mal_fixes' do
    allow(parser).to receive(:mal_fixes).and_return 1 => {name: 'Test'}
    expect(parser.apply_mal_fixes(1, {entry: {name: 'zzzz'}})[:entry][:name]).to eq 'Test'
  end
end
