describe SiteParserWithCache do
  let(:parser) { SiteParserWithCache.new }

  it 'cache' do
    parser.cache = { :zxc => true, 'тест' => 'даyes' }
    parser.save_cache

    expect(SiteParserWithCache.new.cache).to eq(:zxc => true, 'тест' => 'даyes')
  end
end
