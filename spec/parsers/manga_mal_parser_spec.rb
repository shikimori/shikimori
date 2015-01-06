describe MangaMalParser, vcr: { cassette_name: 'manga_mal_parser' } do
  before { allow(SiteParserWithCache).to receive(:load_cache).and_return list: {} }
  before { allow(parser).to receive :save_cache }

  let(:parser) { MangaMalParser.new }
  let(:manga_id) { 4 }

  it 'have correct type' do
    expect(parser.instance_eval { type }).to eq('manga')
  end

  it 'fetches list page' do
    expect(parser.fetch_list_page(0, :all_catalog_url).size).to eq(BaseMalParser::EntriesPerPage)
    expect(parser.list.size).to eq(BaseMalParser::EntriesPerPage)
  end

  it 'fetches updated list page' do
    expect(parser.fetch_list_page(0, :updated_catalog_url).size).to eq(BaseMalParser::EntriesPerPage)
    expect(parser.list.size).to eq(BaseMalParser::EntriesPerPage)
  end

  it 'fetches 3 list pages' do
    expect(parser.fetch_list_pages(limit: 3).size).to eq(3 * BaseMalParser::EntriesPerPage)
    expect(parser.list.size).to eq(3 * BaseMalParser::EntriesPerPage)
  end

  it 'stops when got 0 entries' do
    urls = [parser.instance_eval { all_catalog_url(0) }, parser.instance_eval { all_catalog_url(99999) }, parser.instance_eval { all_catalog_url(2) }]
    allow(parser).to receive(:all_catalog_url).and_return(urls[0], urls[1], urls[2])

    expect(parser.fetch_list_pages(limit: 3).size).to eq(1 * BaseMalParser::EntriesPerPage)
    expect(parser.list.size).to eq(1 * BaseMalParser::EntriesPerPage)
  end

  it 'fetches manga data' do
    data = parser.fetch_entry_data(manga_id)
    expect(data[:name]).to eq('Yokohama Kaidashi Kikou')
    expect(data).to include(:description_mal)
    expect(data[:related]).not_to be_empty
    expect(data).to include(:english)
    expect(data).to include(:synonyms)
    expect(data).to include(:japanese)
    expect(data).to include(:kind)

    expect(data[:volumes]).to be(14)
    expect(data[:chapters]).to be(142)

    expect(data).to include(:released_on)
    expect(data).to include(:aired_on)

    expect(data[:genres]).not_to be_empty
    expect(data[:authors]).not_to be_empty
    expect(data[:publishers]).not_to be_empty

    #data.should include(:rating)
    expect(data).to include(:score)
    expect(data).to include(:ranked)
    expect(data).to include(:popularity)
    expect(data).to include(:members)
    expect(data).to include(:favorites)

    expect(data[:img]).to eq 'http://cdn.myanimelist.net/images/manga/1/4743.jpg'
  end

  it 'fetches manga characters' do
    characters, people = parser.fetch_entry_characters(manga_id)
    expect(characters.size).to be >= 11
    expect(people).to be_empty
  end

  it 'fetches manga people' do
    data = parser.fetch_entry(manga_id)
    expect(data[:entry][:authors]).not_to be_empty
    expect(data[:people].size).to eq(1)
  end

  it 'fetches manga publishers' do
    entry = parser.fetch_entry_data(manga_id)
    expect(entry[:publishers]).not_to be_empty
  end

  it 'fetches manga recommendations' do
    recs = parser.fetch_entry_recommendations(manga_id)
    expect(recs.size).to be >= 17
  end

  it 'fetches manga scores' do
    scores = parser.fetch_entry_scores(manga_id)
    expect(scores.size).to eq(10)
  end

  it 'fetches manga images' do
    images = parser.fetch_entry_images(manga_id)
    expect(images.size).to be >= 5
  end

  it 'fetches the whole entry' do
    expect(parser.fetch_entry(manga_id).size).to eq(6)
  end
end
