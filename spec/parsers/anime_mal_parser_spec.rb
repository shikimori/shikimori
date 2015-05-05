describe AnimeMalParser, vcr: { cassette_name: 'anime_mal_parser' } do
  before { allow(SiteParserWithCache).to receive(:load_cache).and_return list: {} }
  before { allow(parser).to receive :save_cache }

  let(:parser) { AnimeMalParser.new }
  let(:anime_id) { 1 }

  it 'have correct type' do
    expect(parser.instance_eval { type }).to eq 'anime'
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

  it 'fetches anime data' do
    data = parser.fetch_entry_data(anime_id)

    expect(data[:name]).to eq 'Cowboy Bebop'
    expect(data).to include(:description_mal)
    expect(data[:related]).not_to be_empty
    expect(data).to include(:english)
    expect(data).to include(:synonyms)
    expect(data[:japanese]).to eq ['カウボーイビバップ']
    expect(data).to include(:kind)

    expect(data).to include(:episodes)

    expect(data).to include(:released_on)
    expect(data).to include(:aired_on)

    expect(data[:genres]).not_to be_empty
    expect(data[:studios]).not_to be_empty
    expect(data).to include(:duration)

    expect(data).to include(:rating)
    expect(data).to include(:score)
    expect(data).to include(:ranked)
    expect(data).to include(:popularity)
    expect(data).to include(:members)
    expect(data).to include(:favorites)

    expect(data[:img]).to eq 'http://cdn.myanimelist.net/images/anime/4/19644.jpg'
  end

  it 'fetches anime related' do
    data = parser.fetch_entry_data(22043)

    expect(data[:name]).to eq 'Fairy Tail (2014)'
    expect(data[:related]).to have(2).items
  end

  it 'fetches anime characters' do
    characters, people = parser.fetch_entry_characters(anime_id)
    expect(characters.size).to be >= 29
    expect(people.size).to be >= 38
  end

  it 'fetches anime recommendations' do
    recs = parser.fetch_entry_recommendations(anime_id)
    expect(recs.size).to be >= 55
  end

  #it 'fetches anime scores' do
    #scores = parser.fetch_entry_scores(anime_id)
    #expect(scores.size).to eq(10)
  #end

  it 'fetches the whole entry' do
    expect(parser.fetch_entry(anime_id)).to have(4).items
  end

  #describe 'import' do
    #before (:each) {
      #FactoryGirl.create :anime, id: 3234
      #FactoryGirl.create :anime, id: 298, imported_at: DateTime.now
      #parser.fetch_list_page(0)
    #}

    #it 'prepares' do
      #parser.prepare.should have(BaseMalParser::EntriesPerPage-1).items
    #end

    #it 'imports' do
      #expect {
        #parser.import.should have(BaseMalParser::EntriesPerPage-1).items
      #}.to change(Anime, :count).by(BaseMalParser::EntriesPerPage-2)
    #end
  #end
end
