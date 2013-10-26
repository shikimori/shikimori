
require 'spec_helper'

describe AnimedbRuParser do
  before (:each) { SiteParserWithCache.stub(:load_cache).and_return({:list => {}, :animes => {}}) }

  let (:parser) {
    p = AnimedbRuParser.new
    p.stub(:save_cache)
    p
  }

  it 'max_id' do
    parser.fetch_max_id.should eq 6993
  end

  describe 'fetch_anime' do
    it 'works' do
      anime = parser.fetch_anime(6426)

      anime[:russian].should == 'Я и мой слуга из секретной службы'
      anime[:name].should == 'Inu x Boku Secret Service'
      anime[:names].should == ["妖狐x僕SS", "Inu × Boku SS", "Inu x Boku S.S.", "Inuboku Secret Service", "Inu x Boku SS"]
      anime[:screenshots].should have(113).items
      anime[:year].should be(2012)
      anime[:kind].should == 'TV'
    end

    it 'anime w/o russian' do
      parser.fetch_anime(286).should == {
        :id => 286,
        :name => 'Tokechigai',
        :names => ['解けちがい'],
        :screenshots => [],
        :url => 'http://animedb.ru/?id=286',
        :year => 1918,
        :russian => '',
        :kind => nil
      }
    end

    it 'anime ТВ1' do
      parser.fetch_anime(666)[:kind].should == 'TV'
    end

    it 'anime Спэшл' do
      parser.fetch_anime(742)[:kind].should == 'Special'
    end

    it 'anime Фильм' do
      parser.fetch_anime(189)[:kind].should == 'Movie'
    end
  end

  describe 'should_load?' do
    it 'unloaded' do
      parser.should_load?(111).should be_true
    end

    it 'loaded w/o screenshots and new' do
      parser.cache[:animes][111] = {:screenshots => [], :year => 2010}
      parser.should_load?(111).should be_true
    end

    it 'loaded w/o screenshots but old' do
      parser.cache[:animes][111] = {:screenshots => [], :year => 2000}
      parser.should_load?(111).should be_false
    end

    it 'is false for entry with screenshots' do
      parser.cache[:animes][111] = {:screenshots => [1]}
      parser.should_load?(111).should be_false
    end
  end

  describe 'merge' do
    def prepare_data(remote_id, local_id, name, kind)
      anime = FactoryGirl.create :anime, :name => name, :kind => kind, :id => local_id, russian: nil

      fetched_anime = parser.fetch_anime(remote_id)
      parser.cache[:animes][remote_id] = fetched_anime

      [anime, fetched_anime]
    end

    it 'works' do
      anime, fetched_anime = prepare_data(5455, 1, 'K-On!', 'TV')
      parser.merge_russian

      Anime.find(anime.id).russian.should == fetched_anime[:russian]
    end

    it 'works with fixes' do
      anime, fetched_anime = prepare_data(6428, 11285, 'Black★Rock Shooter', 'TV')
      parser.merge_russian

      Anime.find(anime.id).russian.should == fetched_anime[:russian]
    end
  end

  it 'cleanups russian' do
    parser.fetch_anime(4753)[:russian].should == 'Код Гиас: Восставший Лелуш'
  end

  describe 'autoupdate' do
    it 'fetch_new_ids' do
      parser.fetch_ids_with_screenshots.should be_a_kind_of(Array)
    end
  end
end
