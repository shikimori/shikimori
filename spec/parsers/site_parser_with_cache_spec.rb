describe SiteParserWithCache do
  before (:each) { SiteParserWithCache.stub(:cache_name).and_return('test') }

  let (:parser) {
    SiteParserWithCache.new
  }

  it 'cache' do
    parser.cache = {:zxc => true, 'тест' => 'даyes'}
    parser.save_cache

    SiteParserWithCache.new.cache.should == {:zxc => true, 'тест' => 'даyes'}
  end
end
