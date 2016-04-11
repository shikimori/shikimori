describe HentaiAnimeParser, vcr: { cassette_name: 'hentai_anime_parser' } do
  let(:parser) { HentaiAnimeParser.new }
  it { expect(parser.fetch_pages_num).to eq 7 }
  it { expect(parser.fetch_page_links(0).size).to eq(HentaiAnimeParser::PageSize) }

  describe 'fetch_entry' do
    subject(:entry) { parser.fetch_entry identifier }

    describe 'heisa_byouin' do
      let(:identifier) { 'heisa_byouin' }

      its(:id) { is_expected.to eq 'heisa_byouin' }
      its(:names) { is_expected.to eq ['Шаловливые медсестры', 'Heisa Byouin: Naughty Nurses', 'Heisa Byouin', 'Naughty Nurses'] }
      its(:russian) { is_expected.to eq 'Шаловливые медсестры' }
      its(:source) { is_expected.to eq 'http://hentai-anime.ru/heisa_byouin' }

      its(:videos) { is_expected.to have(2).items }
      its(:year) { is_expected.to eq 2003 }

      describe 'last_episode' do
        subject { entry.videos.first }
        it { is_expected.to eq episode: 2, url: 'http://hentai-anime.ru/heisa_byouin/series2?mature=1' }
      end

      describe 'first_episode' do
        subject { entry.videos.last }
        it { is_expected.to eq episode: 1, url: 'http://hentai-anime.ru/heisa_byouin/series1?mature=1' }
      end
    end

    describe 'koakuma_kanojo_the_animation' do
      let(:identifier) { 'koakuma_kanojo_the_animation' }

      its(:id) { is_expected.to eq 'koakuma_kanojo_the_animation' }
      its(:videos) { is_expected.to have(1).items }
      it { expect(entry.videos.first).to eq episode: 1, url: 'http://hentai-anime.ru/koakuma_kanojo_the_animation/series1?mature=1' }
    end
  end

  describe 'fetch_videos' do
    subject(:videos) { parser.fetch_videos episode, url }
    let(:episode) { 1 }

    describe 'sextra_credit' do
      let(:url) { 'http://hentai-anime.ru/sextra_credit/series1' }

      it { is_expected.to have(2).items }

      describe 'first' do
        subject { videos.first }

        its(:episode) { is_expected.to eq episode }
        its(:url) { is_expected.to eq '//myvi.ru/player/embed/html/o60C2X-c5hk7ZKz6EIv8Ka1FJ5DesnXP70C53LXNFUfg1' }
        its(:kind) { is_expected.to eq :unknown }
        its(:language) { is_expected.to eq :russian }
        its(:source) { is_expected.to eq 'http://hentai-anime.ru/sextra_credit/series1' }
        its(:author) { is_expected.to eq '' }
      end

      describe 'last' do
        subject { videos.last }

        its(:episode) { is_expected.to eq episode }
        its(:url) { is_expected.to eq '//vk.com/video_ext.php?oid=169326160&id=163223486&hash=c2f14f4582b787b2' }
        its(:kind) { is_expected.to eq :subtitles }
        its(:language) { is_expected.to eq :english }
        its(:source) { is_expected.to eq 'http://hentai-anime.ru/sextra_credit/series1' }
        its(:author) { is_expected.to eq '' }
      end
    end

    describe 'koakuma_kanojo_the_animation' do
      let(:url) { 'http://hentai-anime.ru/koakuma_kanojo_the_animation/series1' }

      it { is_expected.to have(2).items }
    end
  end
end
