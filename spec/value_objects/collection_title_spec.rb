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
  let(:season) {}
  let(:type) {}
  let(:status) {}
  let(:genres) {}
  let(:studios) {}
  let(:publishers) {}

  describe '#title' do
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
      context 'one type' do
        context 'tv' do
          let(:type) { 'tv' }
          it { is_expected.to eq 'Аниме сериалы' }
        end

        context 'movie' do
          let(:type) { 'movie' }
          it { is_expected.to eq 'Полнометражные аниме' }
        end
      end

      context 'many types' do
        let(:type) { 'tv,movie' }
        it { is_expected.to eq 'Сериалы и Фильмы' }
      end
    end

    describe 'status' do
      context 'anons' do
        let(:status) { 'anons' }
        it { is_expected.to eq 'Анонсы аниме' }
      end

      context 'ongoing' do
        let(:status) { 'ongoing' }
        it { is_expected.to eq 'Онгоинги аниме' }
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
      let(:genres) { build :genre, name: name, kind: klass.name.downcase }
      let(:klass) { Anime }

      context 'magic' do
        let(:name) { 'Magic' }
        it { is_expected.to eq 'Аниме про магию' }
      end

      context 'comedy' do
        let(:name) { 'Comedy' }

        context 'anime' do
          it { is_expected.to eq 'Аниме комедии' }
        end

        context 'manga' do
          let(:klass) { Manga }
          it { is_expected.to eq 'Комедийная манга' }
        end
      end

      context 'romance' do
        let(:name) { 'Romance' }
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

  describe '#manga_conjugation_variant?' do
    subject { collection_title.manga_conjugation_variant? }

    context 'manga with status filter' do
      let(:klass) { Manga }

      context 'many types' do
        let(:type) { 'manga,manhua' }

        context 'status == released' do
          let(:status) { 'released' }
          it { is_expected.to eq true }
        end

        context 'status == latest' do
          let(:status) { 'latest' }
          it { is_expected.to eq true }
        end

        context 'another status' do
          let(:status) { 'anons' }
          it { is_expected.to eq false }
        end
      end

      context 'one type' do
        context 'type == manga' do
          let(:type) { 'manga' }
          it { is_expected.to eq true }
        end

        context 'type != manga' do
          let(:type) { 'manhua' }
          it { is_expected.to eq false }
        end
      end
    end

    context 'manga without status filter' do
      let(:klass) { Manga }
      let(:status) { nil }

      context 'many types' do
        let(:type) { 'manga,manhua' }
        it { is_expected.to eq false }
      end

      context 'one type' do
        context 'type == manga' do
          let(:type) { 'manga' }
          it { is_expected.to eq true }
        end

        context 'type != manga' do
          let(:type) { 'manhua' }
          it { is_expected.to eq false }
        end
      end

      context 'no type' do
        let(:type) { nil }
        it { is_expected.to eq true }
      end
    end
  end
end
