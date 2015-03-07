
#describe WorldArtParser do
  #before { SiteParserWithCache.stub(:load_cache).and_return(list: {}) }

  #let(:parser) {
    #p = WorldArtParser.new
    #p.stub(:save_cache)
    #p
  #}

  #it 'max_id' do
    #parser.fetch_max_id.should be(8168)
  #end

  #it 'fetch_score' do
    #scores = parser.fetch_score(id: 2993)[:scores]
    #scores.should have(10).items
    #scores.sum.should > 120
  #end

  #it 'fetch_anime' do
    #parser.fetch_anime(2629).should == {
      #id: 2629,
      #names: [
        #"Burst Angel",
        #"Bakuretsu Tenshi",
        #"Explosive Angel",
        #"爆裂天使",
        #"爆裂天使バーストエンジェル",
        #"爆裂天使 <バクレツテンシ>"
        #],
        #rus: "Ангелы Смерти [ТВ]",
        #score: 7.2,
        #scores: [0, 5, 9, 28, 50, 72, 113, 123, 97, 41],
        #url: "http://www.world-art.ru/animation/animation.php?id=2629",
        #year: 2004
      #}
  #end
#end
