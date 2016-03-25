describe FindAnimeParser, vcr: { cassette_name: 'find_anime_parser' } do
  let(:parser) { FindAnimeParser.new }

  it { expect(parser.fetch_pages_num).to eq 42 }
  it { expect(parser.fetch_page_links(0)).to have(FindAnimeParser::PageSize).items }

  describe '#fetch_entry' do
    subject(:entry) { parser.fetch_entry identifier }

    describe 'common entry' do
      let(:identifier) { 'attack_on_titan' }

      its(:id) { is_expected.to eq 'attack_on_titan' }
      its(:names) { is_expected.to eq ["Вторжение Гигантов", "Attack on Titan", "Shingeki no Kyojin", "Вторжение Титанов", "Атака Гигантов", "進撃の巨人"] }
      its(:russian) { is_expected.to eq 'Вторжение Гигантов' }
      its(:score) { is_expected.to be_within(1).of 9 }
      its(:description_ru) { is_expected.to be_present }
      its(:source) { is_expected.to eq '© Hollow, http://world-art.ru' }

      its(:videos) { is_expected.to have(26).items }
      its(:year) { is_expected.to eq 2013 }

      describe 'last episode' do
        subject { entry.videos.first }
        it { is_expected.to eq episode: 26, url: 'http://findanime.ru/attack_on_titan/series26?mature=1' }
      end

      describe 'first episode' do
        subject { entry.videos.last }
        it { is_expected.to eq episode: 1, url: 'http://findanime.ru/attack_on_titan/series1?mature=1' }
      end
    end

    describe 'names' do
      let(:identifier) { 'how_to_train_the_ordinary_girl_to_be_a_heroine' }
      its(:names) { is_expected.to eq ["Как воспитать из обычной девушки героиню", "How to Train the Ordinary Girl to be a Heroine", "Saenai Kanojo no Sodate-kata", "Как создать скучную героиню", "Как воспитать героиню", "Saekano", "冴えない彼女の育てかた"] }
    end

    describe 'additioanl names' do
      let(:identifier) { 'gen__ei_wo_kakeru_taiyou' }
      its(:names) { is_expected.to eq ['Солнце, пронзившее иллюзию.', "Gen' ei wo Kakeru Taiyou", 'Il Sole Penetra le Illusioni', '幻影ヲ駆ケル太陽', 'Стремительные солнечные призраки', 'Солнце, покорившее иллюзию' ] }
    end

    describe 'inline videos' do
      let(:identifier) { 'problem_children_are_coming_from_another_world__aren_t_they_____ova' }
      its(:videos) { is_expected.to eq [{episode: 1, url: 'http://findanime.ru/problem_children_are_coming_from_another_world__aren_t_they___ova/series0?mature=1'}] }
    end

    describe 'episode 0 or movie' do
      let(:identifier) { 'seikai_no_dansho___tanjyou_ova' }
      its(:videos) { is_expected.to eq [{episode: 1, url: 'http://findanime.ru/seikai_no_dansho___tanjyou_ova/series0?mature=1'}] }
    end

    describe 'amv' do
      let(:identifier) { 'steel_fenders' }
      its(:categories) { is_expected.to eq ['amv'] }
    end

    describe 'episodes' do
      let(:identifier) { 'full_moon_wo_sagashite' }
      its(:episodes) { is_expected.to eq 52 }
    end
  end

  describe '#fetch_videos' do
    subject(:videos) { parser.fetch_videos episode, url }
    let(:episode) { 1 }
    let(:url) { 'http://findanime.ru/strike_the_blood/series1?mature=1' }

    it 'has 16 items' do
      expect(subject.size).to eq(16)
    end

    describe 'first' do
      subject { videos.first }

      its(:episode) { is_expected.to eq episode }
      its(:url) { is_expected.to eq "//vk.com/video_ext.php?oid=-51137404&id=166106853&hash=ccd5e4a17d189206" }
      its(:kind) { is_expected.to eq :raw }
      its(:language) { is_expected.to eq :russian }
      its(:source) { is_expected.to eq "http://findanime.ru/strike_the_blood/series1?mature=1" }
      its(:author) { is_expected.to eq '' }
    end

    describe 'last' do
      subject { videos[-4] }

      its(:kind) { is_expected.to eq :fandub }
      its(:author) { is_expected.to eq 'JazzWay Anime' }
    end
  end

  describe '#extract_language' do
    subject { parser.extract_language text }

    describe :английские_сабы do
      let(:text) { 'Английские сабы' }
      it { is_expected.to eq :english }
    end

    describe 'other' do
      let(:text) { 'other' }
      it { is_expected.to eq :russian }
    end
  end

  describe '#extract_kind' do
    subject { parser.extract_kind text }

    describe :озвучка do
      let(:text) { 'Озвучка+сабы' }
      it { is_expected.to eq :fandub }
    end

    describe :озвучка do
      let(:text) { 'Озвучка' }
      it { is_expected.to eq :fandub }
    end

    describe :сабы do
      let(:text) { 'Сабы' }
      it { is_expected.to eq :subtitles }
    end

    describe :английские_сабы do
      let(:text) { 'Английские сабы' }
      it { is_expected.to eq :subtitles }
    end

    describe :хардсаб do
      let(:text) { 'Хардсаб' }
      it { is_expected.to eq :subtitles }
    end

    describe :хардсаб_сабы do
      let(:text) { 'Хардсаб+сабы' }
      it { is_expected.to eq :subtitles }
    end

    describe :оригинал do
      let(:text) { 'Оригинал' }
      it { is_expected.to eq :raw }
    end

    describe 'mismatch' do
      let(:text) { 'mismatch' }
      specify { expect{subject}.to raise_error RuntimeError, "unexpected russian kind: 'mismatch'" }
    end
  end

  describe '#fetch_pages' do
    before { allow(parser).to receive(:fetch_entry).and_return id: true }
    let(:pages) { 3 }

    it 'fetches pages' do
      items = parser.fetch_pages(0..(pages-1))
      expect(items.size).to be >= ReadMangaParser::PageSize * pages - 1
    end
  end
end
