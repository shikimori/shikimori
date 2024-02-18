class SitemapController < ShikimoriController
  def index # rubocop:disable all
    # TODO: exclude db entries where source in description_ru is empty
    if params[:format] == 'xml'
      @animes = DbEntries::WithDescriptionQuery
        .with_description_ru_source(Anime)
        .where.not(kind: :special)
        .order(updated_at: :desc)
        .limit(5)
      @mangas = DbEntries::WithDescriptionQuery
        .with_description_ru_source(Manga)
        .order(updated_at: :desc)
        .limit(5)
    end

    og page_title: 'Карта сайта'
    @last_animepage_change = DateTime.parse('2011-06-05 15:12:43')

    latest_seasons = [3, 0, -3, -6, -9, -12, -15, -18]
      .map { |interval| Titles::SeasonTitle.new(interval.months.from_now, :season_year, Anime) }
      .map do |season|
        [
          'Аниме ' + season.catalog_title
            .gsub('Зима', 'зимы')
            .gsub('Весна', 'весны')
            .gsub('Лето', 'лета')
            .gsub('Осень', 'осени'),
          animes_collection_url(season.url_params)
        ]
      end

    @anime_seasons = [
      # ['Последние аниме', animes_collection_url(season: 'latest')],
      ['Каталог аниме', animes_collection_url],
      ['Аниме сериалы', animes_collection_url(type: :tv)],
      ['Полнометражные аниме', animes_collection_url(type: :movie)]
    ] +
      latest_seasons +
      (2000..Time.zone.now.year).to_a.reverse.map do |year|
        ["Аниме #{year} года", animes_collection_url(season: year)]
      end

    @anime_genres_demographic = sitemap_genres kind: :demographic
    @anime_genres_genre = sitemap_genres kind: :genre
    @anime_genres_theme = sitemap_genres kind: :theme

    @anime_misc_genres = [
      ['Аниме комедия романтика', animes_collection_url(genre_v2: '4-Comedy,22-Romance')],
      ['Аниме комедия школа', animes_collection_url(genre_v2: '4-Comedy,23-School')],
      ['Аниме сёдзё комедия', animes_collection_url(genre_v2: '25-Shoujo,4-Comedy')],
      ['Аниме сёдзё школа', animes_collection_url(genre_v2: '25-Shoujo,23-School')],
      ['Аниме школа романтика', animes_collection_url(genre_v2: '23-School,22-Romance')]
    ]
    @manga_seasons = [
      ['Каталог манги', mangas_collection_url]
    ]
    @ranobe_forums = [
      ['Каталог ранобэ', ranobe_collection_url]
    ]
    @forums = [
      ['Аниме студии', studios_url],
      ['График онгоингов', ongoings_pages_url],
      ['Турниры и голосования', contests_url]
    ] +
      Forums::List.new.to_a
      .reject { |v| v.url.include? 'my_clubs' }
      .map { |v| [v.name, v.url] }
  end

private

  def sitemap_genres kind:
    GenreV2
      .where(entry_type: 'Anime', kind:)
      .filter_map do |genre_v2|
        next if genre_v2.censored?

        sitemap_genre genre_v2
      end
  end

  def sitemap_genre genre_v2
    [
      Titles::CollectionTitle.new(
        klass: Anime,
        genres_v2: genre_v2,
        user: nil,
        season: nil,
        kind: nil,
        status: nil,
        genres: nil,
        studios: nil,
        publishers: nil
      ).title(true),
      animes_collection_url(genre_v2: genre_v2.to_param)
    ]
  end
end
