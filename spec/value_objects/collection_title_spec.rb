describe CollectionTitle do
  let(:collection_title) do
    CollectionTitle.new(
      klass: klass,
      user: user,
      season: season,
      type: type,
      status: status,
      genres: genres,
      studios: studios,
      publishers: publishers
    )
  end
  let(:klass) { Anime }
  let(:user) { nil }
  let(:season) { }
  let(:type) { }
  let(:status) { }
  let(:genres) { }
  let(:studios) { }
  let(:publishers) { }

  subject(:title) { collection_title.title }

  context 'no params' do
    context 'anime' do
      context 'guest' do
        it { is_expected.to eq 'Лучшие аниме' }
      end

      context 'authenticated' do
        let(:user) { build :user }
        it { is_expected.to eq 'Аниме' }
      end
    end

    context 'manga' do
      let(:klass) { Manga }
      it { is_expected.to eq 'Манга' }
    end
  end

  describe 'type' do
    context 'tv' do
      let(:type) { 'tv' }
      it { is_expected.to eq 'Аниме сериалы' }
    end

    context 'movie' do
      let(:type) { 'movie' }
      it { is_expected.to eq 'Полнометражные аниме' }
    end
  end

  describe 'status' do
    context 'anons' do
      let(:status) { 'anons' }
      it { is_expected.to eq 'Аниме анонсы' }
    end

    context 'ongoing',:focus do
      let(:status) { 'ongoing' }
      it { is_expected.to eq 'Аниме онгоинги' }
    end

    context 'released' do
      let(:status) { 'released' }

      context 'anime' do
        it { is_expected.to eq 'Вышедшие аниме' }
      end

      context 'manga' do
        let(:klass) { Manga }
        it { is_expected.to eq 'Вышедшая манга' }
      end

      context 'novel' do
        let(:klass) { Manga }
        let(:type) { 'novel' }
        it { is_expected.to eq 'Вышедшие новеллы' }
      end
    end
  end

  describe 'genres' do
    context 'magic' do
      let(:genres) { build :genre, name: 'Magic' }
      it { is_expected.to eq 'Аниме про магию' }
    end

    context 'comedy' do
      let(:genres) { build :genre, name: 'Comedy' }

      context 'anime' do
        it { is_expected.to eq 'Комедийные аниме' }
      end

      context 'manga' do
        let(:klass) { Manga }
        it { is_expected.to eq 'Комедийная манга' }
      end
    end

    context 'romance' do
      let(:genres) { build :genre, name: 'Romance' }
      it { is_expected.to eq 'Романтические аниме про любовь' }
    end
  end

  describe 'studios' do
    context 'Fofofo' do
      let(:studios) { build :studio, name: 'Fofofo' }
      it { is_expected.to eq 'Аниме студии Fofofo' }
    end
  end

  describe 'publishers' do
    let(:klass) { Manga }

    context 'Fofofo' do
      let(:publishers) { build :publisher, name: 'Fofofo' }
      it { is_expected.to eq 'Манга издателя Fofofo' }
    end
  end
end
