describe HentaiAnimeParser do
  before { SiteParserWithCache.stub(:load_cache).and_return entries: {} }
  before { SiteParserWithCache.stub :save_cache }

  let(:parser) { HentaiAnimeParser.new }
  it { parser.fetch_pages_num.should eq 7 }
  it { parser.fetch_page_links(0).should have(HentaiAnimeParser::PageSize).items }

  describe :fetch_entry do
    subject(:entry) { parser.fetch_entry identifier }

    let(:identifier) { 'heisa_byouin' }

    its(:id) { should eq 'heisa_byouin' }
    its(:names) { should eq ['Шаловливые медсестры', 'Heisa Byouin: Naughty Nurses', 'Heisa Byouin', 'Naughty Nurses'] }
    its(:russian) { should eq 'Шаловливые медсестры' }
    its(:source) { should eq 'http://hentai-anime.ru/heisa_byouin' }
    its(:videos) { should have(2).items }
    its(:year) { should eq 2003 }

    describe :last_episode do
      subject { entry.videos.first }
      it { should eq episode: 2, url: 'http://hentai-anime.ru/heisa_byouin/series2?mature=1' }
    end

    describe :first_episode do
      subject { entry.videos.last }
      it { should eq episode: 1, url: 'http://hentai-anime.ru/heisa_byouin/series1?mature=1' }
    end
  end

  describe :fetch_videos do
    subject(:videos) { parser.fetch_videos episode, url }
    let(:episode) { 1 }
    let(:url) { 'http://hentai-anime.ru/sextra_credit/series1' }

    it { should have(2).items }

    describe :first do
      subject { videos.first }

      its(:episode) { should eq episode }
      its(:url) { should eq 'http://myvi.ru/ru/flash/player/o60C2X-c5hk7ZKz6EIv8Ka1FJ5DesnXP70C53LXNFUfg1' }
      its(:kind) { should eq :unknown }
      its(:language) { should eq :russian }
      its(:source) { should eq 'http://hentai-anime.ru/sextra_credit/series1' }
      its(:author) { should eq '' }
    end

    describe :last do
      subject { videos.last }

      its(:episode) { should eq episode }
      its(:url) { should eq 'http://vk.com/video_ext.php?oid=169326160&id=163223486&hash=c2f14f4582b787b2&hd=3' }
      its(:kind) { should eq :subtitles }
      its(:language) { should eq :english }
      its(:source) { should eq 'http://hentai-anime.ru/sextra_credit/series1' }
      its(:author) { should eq '' }
    end
  end
end
