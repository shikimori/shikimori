describe Titles::AnimeKeywords do
  let(:anime_keywords) do
    Titles::AnimeKeywords.new(
      klass:,
      season:,
      kind:,
      genres_v2:,
      studios:,
      publishers:
    )
  end

  describe '#keywords' do
    subject { anime_keywords.keywords }

    let(:klass) { Anime }
    let(:season) { 'winter_2004' }
    let(:kind) { 'tv' }
    let(:genres_v2) do
      build :genre_v2,
        name: 'Magic',
        russian: 'Магия',
        entry_type: klass.base_class.name
    end
    let(:studios) { build :studio, name: 'Fofofo Studio' }
    let(:publishers) { build :publisher, name: 'Fofofo Publisher' }

    context 'all' do
      it do
        is_expected.to eq '
          зимы 2004 аниме сериалы жанр Magic Магия
          студия Fofofo Studio издатель Fofofo Publisher
          список каталог база
        '.delete("\n").squeeze(' ').strip
      end
    end

    context 'without genres' do
      let(:genres_v2) { nil }
      it do
        is_expected.to eq '
          зимы 2004 аниме сериалы
          студия Fofofo Studio издатель Fofofo Publisher
          список каталог база
        '.delete("\n").squeeze(' ').strip
      end
    end
  end
end
