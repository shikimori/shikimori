describe FindAnimeParser, vcr: { cassette_name: 'find_anime_parser' } do
  let(:parser) { FindAnimeParser.new }

  it { expect(parser.fetch_pages_num).to eq 42 }
  it { expect(parser.fetch_page_links(0)).to have(FindAnimeParser::PageSize).items }

  describe 'fetch_entry' do
    subject(:entry) { parser.fetch_entry identifier }

    describe 'common_entry' do
      let(:identifier) { 'attack_on_titan' }

      its(:id) { should eq 'attack_on_titan' }
      its(:names) { should eq ["Вторжение Гигантов", "Attack on Titan", "Shingeki no Kyojin", "Вторжение Титанов", "Атака Гигантов", "進撃の巨人"] }
      its(:russian) { should eq 'Вторжение Гигантов' }
      its(:score) { should be_within(1).of 9 }
      its(:description) { should be_present }
      its(:source) { should eq '© Hollow, http://world-art.ru' }

      its(:videos) { should have(26).items }
      its(:year) { should eq 2013 }

      describe 'last_episode' do
        subject { entry.videos.first }
        it { should eq episode: 26, url: 'http://findanime.ru/attack_on_titan/series26?mature=1' }
      end

      describe 'first_episode' do
        subject { entry.videos.last }
        it { should eq episode: 1, url: 'http://findanime.ru/attack_on_titan/series1?mature=1' }
      end
    end

    describe 'additioanl_names' do
      let(:identifier) { 'gen__ei_wo_kakeru_taiyou' }
      its(:names) { should eq ['Солнце, пронзившее иллюзию.', "Gen' ei wo Kakeru Taiyou", 'Il Sole Penetra le Illusioni', '幻影ヲ駆ケル太陽', 'Стремительные солнечные призраки', 'Солнце, покорившее иллюзию' ] }
    end

    describe 'inline_videos' do
      let(:identifier) { 'problem_children_are_coming_from_another_world__aren_t_they_____ova' }
      its(:videos) { should eq [{episode: 1, url: 'http://findanime.ru/problem_children_are_coming_from_another_world__aren_t_they___ova/series0?mature=1'}] }
    end

    describe 'episode_0_or_movie' do
      let(:identifier) { 'seikai_no_dansho___tanjyou_ova' }
      its(:videos) { should eq [{episode: 1, url: 'http://findanime.ru/seikai_no_dansho___tanjyou_ova/series0?mature=1'}] }
    end

    describe 'amv' do
      let(:identifier) { 'steel_fenders' }
      its(:categories) { should eq ['amv'] }
    end

    describe 'episodes' do
      let(:identifier) { 'full_moon_wo_sagashite' }
      its(:episodes) { should eq 52 }
    end
  end

  describe 'fetch_videos' do
    subject(:videos) { parser.fetch_videos episode, url }
    let(:episode) { 1 }
    let(:url) { 'http://findanime.ru/strike_the_blood/series1?mature=1' }

    it 'has 16 items' do
      expect(subject.size).to eq(16)
    end

    describe 'first' do
      subject { videos.first }

      its(:episode) { should eq episode }
      its(:url) { should eq "https://vk.com/video_ext.php?oid=-51137404&id=166106853&hash=ccd5e4a17d189206&hd=3" }
      its(:kind) { should eq :raw }
      its(:language) { should eq :russian }
      its(:source) { should eq "http://findanime.ru/strike_the_blood/series1?mature=1" }
      its(:author) { should eq '' }
    end

    describe 'last' do
      subject { videos[-4] }

      its(:kind) { should eq :fandub }
      its(:author) { should eq 'JazzWay Anime' }
    end

    #describe :special do
      #subject { videos.find {|v| v.author == 'JAM & Ancord & Nika Lenina' } }
      #its(:url) { should eq 'http://vk.com/video_ext.php?oid=-23431986&id=166249671&hash=dafc64b82410643c&hd=3' }
      #its(:kind) { should eq :fandub }
    #end
  end

  describe 'extract_language' do
    subject { parser.extract_language text }

    describe :английские_сабы do
      let(:text) { 'Английские сабы' }
      it { should eq :english }
    end

    describe 'other' do
      let(:text) { 'other' }
      it { should eq :russian }
    end
  end

  describe 'extract_kind' do
    subject { parser.extract_kind text }

    describe :озвучка do
      let(:text) { 'Озвучка+сабы' }
      it { should eq :fandub }
    end

    describe :озвучка do
      let(:text) { 'Озвучка' }
      it { should eq :fandub }
    end

    describe :сабы do
      let(:text) { 'Сабы' }
      it { should eq :subtitles }
    end

    describe :английские_сабы do
      let(:text) { 'Английские сабы' }
      it { should eq :subtitles }
    end

    describe :хардсаб do
      let(:text) { 'Хардсаб' }
      it { should eq :subtitles }
    end

    describe :хардсаб_сабы do
      let(:text) { 'Хардсаб+сабы' }
      it { should eq :subtitles }
    end

    describe :оригинал do
      let(:text) { 'Оригинал' }
      it { should eq :raw }
    end

    describe 'mismatch' do
      let(:text) { 'mismatch' }
      specify { expect{subject}.to raise_error }
    end
  end

  describe 'fetch_pages' do
    before { allow(parser).to receive(:fetch_entry).and_return id: true }
    let(:pages) { 3 }

    it 'fetches pages' do
      items = parser.fetch_pages(0..(pages-1))
      expect(items.size).to be >= ReadMangaParser::PageSize * pages - 1
    end
  end
end
