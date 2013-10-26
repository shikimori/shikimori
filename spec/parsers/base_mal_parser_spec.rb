require 'spec_helper'

describe BaseMalParser do
  before { SiteParserWithCache.stub(:load_cache).and_return list: {} }

  let (:parser) {
    p = BaseMalParser.new
    p.stub(:save_cache)
    p
  }

  describe 'load' do
    it 'genres' do
      genre = FactoryGirl.create :genre
      parser.genres.should have(1).item
      parser.genres[genre.id].name.should eq genre.name
    end

    it 'studios' do
      studio = FactoryGirl.create :studio
      parser.studios.should have(1).item
      parser.studios[studio.id].name.should eq studio.name
    end

    it 'publishers' do
      publisher = FactoryGirl.create :publisher
      parser.publishers.should have(1).item
      parser.publishers[publisher.id].name.should eq publisher.name
    end
  end

  it 'applies mal_fixes' do
    parser.stub(:mal_fixes).and_return 1 => {name: 'Test'}
    parser.apply_mal_fixes(1, {entry: {name: 'zzzz'}})[:entry][:name].should eq 'Test'
  end
end
