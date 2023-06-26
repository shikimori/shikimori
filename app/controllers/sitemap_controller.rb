class SitemapController < ShikimoriController
  def index
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
      ['Полнометражные аниме', animes_collection_url(type: :movie)],
    ] +
      latest_seasons +
      (2000..Time.zone.now.year).to_a.reverse.map do |year|
        ["Аниме #{year} года", animes_collection_url(season: year)]
      end

    @anime_genres = [
      ['Аниме боевые искусства', animes_collection_url(genre: '17-Martial-Arts')],
      ['Аниме драма', animes_collection_url(genre: '8-Drama')],
      ['Аниме гарем', animes_collection_url(genre: '35-Harem')],
      ['Аниме комедия', animes_collection_url(genre: '4-Comedy')],
      ['Детективные аниме', animes_collection_url(genre: '7-Mystery')],
      ['Аниме приключения', animes_collection_url(genre: '2-Adventure')],
      ['Аниме про вампиров', animes_collection_url(genre: '32-Vampire')],
      ['Аниме про демонов', animes_collection_url(genre: '6-Demons')],
      ['Аниме про космос', animes_collection_url(genre: '29-Space')],
      ['Аниме про любовь', animes_collection_url(genre: '22-Romance')],
      ['Аниме про магию', animes_collection_url(genre: '16-Magic')],
      ['Аниме про самураев', animes_collection_url(genre: '21-Samurai')],
      ['Аниме про спорт', animes_collection_url(genre: '30-Sports')],
      ['Аниме про школу', animes_collection_url(genre: '23-School')],
      ['Аниме ужасы', animes_collection_url(genre: '14-Horror')],
      ['Аниме фантастика', animes_collection_url(genre: '24-Sci-Fi')],
      ['Аниме хентай', animes_collection_url(genre: '12-Hentai')],
      ['Аниме яой', animes_collection_url(genre: '33-Yaoi')],
      ['Меха аниме', animes_collection_url(genre: '18-Mecha')],
      ['Сверхъестественное аниме', animes_collection_url(genre: '37-Supernatural')],
      ['Сёдзё аниме', animes_collection_url(genre: '25-Shoujo')],
      ['Сёнен аниме', animes_collection_url(genre: '27-Shounen')],
      ['Сёнен-Ай аниме', animes_collection_url(genre: '28-Shounen-Ai')],
      ['Сэйнэн аниме', animes_collection_url(genre: '42-Seinen')],
      ['Детское аниме', animes_collection_url(genre: '15-Kids')],
      ['Фэнтези аниме', animes_collection_url(genre: '10-Fantasy')],
      ['Этти аниме', animes_collection_url(genre: '9-Ecchi')],
      ['Юри аниме', animes_collection_url(genre: '34-Yuri')]
    ]
    @anime_misc_genres = [
      ['Аниме безумие', animes_collection_url(genre: '5-Dementia')],
     # ['Аниме гендерная интрига', animes_collection_url(genre: '44-Gender-Bender')],
      ['Аниме комедия романтика', animes_collection_url(genre: '4-Comedy,22-Romance')],
      ['Аниме комедия школа', animes_collection_url(genre: '4-Comedy,23-School')],
      ['Аниме повседневность', animes_collection_url(genre: '36-Slice-of-Life')],
      ['Аниме про полицию', animes_collection_url(genre: '39-Police')],
      ['Аниме про сверхспособности', animes_collection_url(genre: '31-Super-Power')],
      ['Аниме сёдзё комедия', animes_collection_url(genre: '25-Shoujo,4-Comedy')],
      ['Аниме сёдзё школа', animes_collection_url(genre: '25-Shoujo,23-School')],
      ['Аниме школа романтика', animes_collection_url(genre: '23-School,22-Romance')],
      ['Аниме экшен', animes_collection_url(genre: '1-Action')],
      ['Аниме про машины', animes_collection_url(genre: '3-Cars')],
      ['Аниме жанра игры', animes_collection_url(genre: '11-Game')],
      ['Аниме жанра музыка', animes_collection_url(genre: '19-Music')],
      ['Аниме с оружием', animes_collection_url(genre: '38-Military')],
      ['Дзёсэй аниме', animes_collection_url(genre: '43-Josei')],
      ['Историческое аниме', animes_collection_url(genre: '13-Historical')],
      ['Психологическое аниме', animes_collection_url(genre: '40-Psychological')],
      ['Сёдзё-Ай аниме', animes_collection_url(genre: '26-Shoujo-Ai')],
      ['Триллер аниме', animes_collection_url(genre: '41-Thriller')]
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
      ['Турниры и голосования', contests_url],
    ] +
      Forums::List.new.to_a
      .reject { |v| v.url.include? 'my_clubs' }
      .map { |v| [v.name, v.url] }
  end
end
