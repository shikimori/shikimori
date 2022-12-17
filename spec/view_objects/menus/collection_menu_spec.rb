describe Menus::CollectionMenu do
  include_context :view_context_stub

  let(:klass) { Anime }
  let(:view) { Menus::CollectionMenu.new klass }

  describe '#sorted_genres' do
    let!(:genre_1) { create :genre, position: 1, kind: :anime }
    let!(:genre_2) { create :genre, position: 2, kind: :anime }
    let!(:genre_3) { create :genre, position: 3, kind: :manga }

    it { expect(view.sorted_genres).to eq [genre_1, genre_2] }
  end

  describe '#kinds' do
    context 'anime' do
      it do
        expect(view.kinds.first).to be_kind_of Titles::KindTitle
        expect(view.kinds.map(&:text)).to eq %w[tv movie ova ona special music]
      end
    end

    context 'manga' do
      let(:klass) { Manga }
      it do
        expect(view.kinds.first).to be_kind_of Titles::KindTitle
        expect(view.kinds.map(&:text)).to eq %w[
          manga manhwa manhua one_shot doujin
        ]
      end
    end

    context 'ranobe' do
      let(:klass) { Ranobe }
      it do
        expect(view.kinds.first).to be_kind_of Titles::KindTitle
        expect(view.kinds.map(&:text)).to eq %w[
          light_novel novel
        ]
      end
    end
  end

  describe '#statuses' do
    it do
      expect(view.statuses.first).to be_kind_of Titles::StatusTitle
      expect(view.statuses.map(&:text)).to eq %w[anons ongoing released latest]
    end
  end

  describe '#seasons' do
    let(:texts) { view.seasons.map(&:text) }
    it { expect(view.seasons.first).to be_kind_of Titles::SeasonTitle }

    describe do
      include_context :timecop, '2022-10-11'
      it do
        expect(texts).to eq %w[
          winter_2023 fall_2022 summer_2022 spring_2022
          2022 2021 2019_2020 2014_2018 2010_2013
          2000_2010 199x 198x ancient
        ]
      end
    end

    describe do
      include_context :timecop, '2027-03-11'
      it do
        expect(texts).to eq %w[
          summer_2027 spring_2027 winter_2027 fall_2026
          2027 2026 2024_2025 2019_2023 2010_2018
          2000_2010 199x 198x ancient
        ]
      end
    end
  end

  describe '#show_sorting?' do
    let(:view_context_params) do
      {
        controller: controller_name,
        search: search,
        q: q
      }
    end
    let(:controller_name) { 'animes_collection' }
    let(:search) { '' }
    let(:q) { '' }

    it { expect(view).to be_show_sorting }

    context 'recommendations' do
      let(:controller_name) { 'recommendations' }
      it { expect(view).to_not be_show_sorting }
    end

    context 'search' do
      let(:search) { 'z' }
      it { expect(view).to_not be_show_sorting }
    end

    context 'q' do
      let(:q) { 'z' }
      it { expect(view).to_not be_show_sorting }
    end
  end

  describe '#anime?, #ranobe?' do
    context 'anime' do
      let(:klass) { Anime }
      it { expect(view).to be_anime }
      it { expect(view).to_not be_ranobe }
    end

    context 'manga' do
      let(:klass) { Manga }
      it { expect(view).to_not be_anime }
      it { expect(view).to_not be_ranobe }
    end

    context 'ranobe' do
      let(:klass) { Ranobe }
      it { expect(view).to_not be_anime }
      it { expect(view).to be_ranobe }
    end
  end
end
