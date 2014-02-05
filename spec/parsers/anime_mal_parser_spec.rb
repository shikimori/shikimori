require 'spec_helper'

describe AnimeMalParser do
  before { SiteParserWithCache.stub(:load_cache).and_return list: {} }
  before { parser.stub :save_cache }

  let(:parser) { AnimeMalParser.new }
  let(:anime_id) { 1 }

  it 'have correct type' do
    parser.instance_eval { type }.should eq 'anime'
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

  it 'fetches anime data' do
    data = parser.fetch_entry_data(anime_id)

    data[:name].should eq 'Cowboy Bebop'
    data.should include(:description_mal)
    data[:related].should_not be_empty
    data.should include(:english)
    data.should include(:synonyms)
    data[:japanese].should eq ['カウボーイビバップ']
    data.should include(:kind)

    data.should include(:episodes)

    data.should include(:released_on)
    data.should include(:aired_on)

    data[:genres].should_not be_empty
    data[:studios].should_not be_empty
    data.should include(:duration)

    data.should include(:rating)
    data.should include(:score)
    data.should include(:ranked)
    data.should include(:popularity)
    data.should include(:members)
    data.should include(:favorites)

    data[:img].should eq 'http://cdn.myanimelist.net/images/anime/4/19644.jpg'
  end

  it 'fetches anime characters' do
    characters, people = parser.fetch_entry_characters(anime_id)
    characters.should have_at_least(29).items
    people.should have_at_least(38).items
  end

  it 'fetches anime recommendations' do
    recs = parser.fetch_entry_recommendations(anime_id)
    recs.should have_at_least(55).items
  end

  it 'fetches anime scores' do
    scores = parser.fetch_entry_scores(anime_id)
    scores.should have(10).items
  end

  it 'fetches anime images' do
    images = parser.fetch_entry_images(anime_id)
    images.should have(7).items
  end

  it 'fetches the whole entry' do
    parser.fetch_entry(anime_id).should have(6).items
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
