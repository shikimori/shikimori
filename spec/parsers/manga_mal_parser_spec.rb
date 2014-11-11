describe MangaMalParser do
  before { SiteParserWithCache.stub(:load_cache).and_return list: {} }
  before { parser.stub :save_cache }

  let(:parser) { MangaMalParser.new }
  let(:manga_id) { 4 }

  it 'have correct type' do
    parser.instance_eval { type }.should == 'manga'
  end

  it 'fetches list page' do
    parser.fetch_list_page(0, :all_catalog_url).should have(BaseMalParser::EntriesPerPage).items
    parser.list.should have(BaseMalParser::EntriesPerPage).items
  end

  it 'fetches updated list page' do
    parser.fetch_list_page(0, :updated_catalog_url).should have(BaseMalParser::EntriesPerPage).items
    parser.list.should have(BaseMalParser::EntriesPerPage).items
  end

  it 'fetches 3 list pages' do
    parser.fetch_list_pages(limit: 3).should have(3 * BaseMalParser::EntriesPerPage).items
    parser.list.should have(3 * BaseMalParser::EntriesPerPage).items
  end

  it 'stops when got 0 entries' do
    urls = [parser.instance_eval { all_catalog_url(0) }, parser.instance_eval { all_catalog_url(99999) }, parser.instance_eval { all_catalog_url(2) }]
    parser.stub(:all_catalog_url).and_return(urls[0], urls[1], urls[2])

    parser.fetch_list_pages(limit: 3).should have(1 * BaseMalParser::EntriesPerPage).items
    parser.list.should have(1 * BaseMalParser::EntriesPerPage).items
  end

  it 'fetches manga data' do
    data = parser.fetch_entry_data(manga_id)
    data[:name].should == 'Yokohama Kaidashi Kikou'
    data.should include(:description_mal)
    data[:related].should_not be_empty
    data.should include(:english)
    data.should include(:synonyms)
    data.should include(:japanese)
    data.should include(:kind)

    data[:volumes].should be(14)
    data[:chapters].should be(142)

    data.should include(:released_on)
    data.should include(:aired_on)

    data[:genres].should_not be_empty
    data[:authors].should_not be_empty
    data[:publishers].should_not be_empty

    #data.should include(:rating)
    data.should include(:score)
    data.should include(:ranked)
    data.should include(:popularity)
    data.should include(:members)
    data.should include(:favorites)

    data[:img].should eq 'http://cdn.myanimelist.net/images/manga/1/4743.jpg'
  end

  it 'fetches manga characters' do
    characters, people = parser.fetch_entry_characters(manga_id)
    characters.should have_at_least(11).items
    people.should be_empty
  end

  it 'fetches manga people' do
    data = parser.fetch_entry(manga_id)
    data[:entry][:authors].should_not be_empty
    data[:people].should have(1).item
  end

  it 'fetches manga publishers' do
    entry = parser.fetch_entry_data(manga_id)
    entry[:publishers].should_not be_empty
  end

  it 'fetches manga recommendations' do
    recs = parser.fetch_entry_recommendations(manga_id)
    recs.should have_at_least(17).items
  end

  it 'fetches manga scores' do
    scores = parser.fetch_entry_scores(manga_id)
    scores.should have(10).items
  end

  it 'fetches manga images' do
    images = parser.fetch_entry_images(manga_id)
    images.should have_at_least(5).items
  end

  it 'fetches the whole entry' do
    parser.fetch_entry(manga_id).should have(6).items
  end
end
