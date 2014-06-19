class SitemapController < ShikimoriController
  def index
    if params[:format] == 'xml'
      @animes = Anime
        .where("description != '' or description is not null")
        .where("source = '' or source is null")
        .where.not(kind: 'Special')
        .order(updated_at: :desc)
      @mangas = Manga
        .where("description != '' or description is not null")
        .where("source = '' or source is null")
        .order(updated_at: :desc)
    end

    @page_title = 'Карта сайта'
    @last_animepage_change = DateTime.parse('2011-06-05 15:12:43')

    @anime_sections = [
      #['Последние аниме', animes_url(season: 'latest')],
      ['Каталог аниме', animes_url],
      ['Аниме сериалы', animes_url(type: 'TV')],
      ['Полнометражные аниме', animes_url(type: 'Movie')],
      ['Аниме лета 2014 года', animes_url(season: 'summer_2011')],
      ['Аниме весны 2014 года', animes_url(season: 'spring_2011')],
      ['Аниме зимы 2014 года', animes_url(season: 'winter_2011')],
      ['Аниме 2014 года', animes_url(season: 2014)],
      ['Аниме 2013 года', animes_url(season: 2013)],
      ['Аниме 2012 года', animes_url(season: 2012)],
      ['Аниме 2011 года', animes_url(season: 2011)],
      ['Аниме 2010 года', animes_url(season: 2010)],
      ['Аниме 2009 года', animes_url(season: 2009)],
      ['Аниме 2008 года', animes_url(season: 2008)]
    ]
    @anime_genres = [
      ['Аниме боевые искусства', animes_url(genre: '17-Martial-Arts')],
      ['Аниме драма', animes_url(genre: '8-Drama')],
      ['Аниме гарем', animes_url(genre: '35-Harem')],
      ['Аниме комедия', animes_url(genre: '4-Comedy')],
      ['Аниме мистика', animes_url(genre: '7-Mystery')],
      ['Аниме приключения', animes_url(genre: '2-Adventure')],
      ['Аниме про вампиров', animes_url(genre: '32-Vampire')],
      ['Аниме про демонов', animes_url(genre: '6-Demons')],
      ['Аниме про космос', animes_url(genre: '29-Space')],
      ['Аниме про любовь', animes_url(genre: '22-Romance')],
      ['Аниме про магию', animes_url(genre: '16-Magic')],
      ['Аниме про самураев', animes_url(genre: '21-Samurai')],
      ['Аниме про спорт', animes_url(genre: '30-Sports')],
      ['Аниме про школу', animes_url(genre: '23-School')],
      ['Аниме ужасы', animes_url(genre: '14-Horror')],
      ['Аниме фантастика', animes_url(genre: '24-Sci-Fi')],
      ['Аниме хентай', animes_url(genre: '12-Hentai')],
      ['Аниме яой', animes_url(genre: '33-Yaoi')],
      ['Меха аниме', animes_url(genre: '18-Mecha')],
      ['Сверхъестественное аниме', animes_url(genre: '37-Supernatural')],
      ['Сёдзё аниме', animes_url(genre: '25-Shoujo')],
      ['Сёнен аниме', animes_url(genre: '27-Shounen')],
      ['Сёнен-Ай аниме', animes_url(genre: '28-Shounen-Ai')],
      ['Сэйнэн аниме', animes_url(genre: '42-Seinen')],
      ['Детское аниме', animes_url(genre: '15-Kids')],
      ['Фэнтези аниме', animes_url(genre: '10-Fantasy')],
      ['Этти аниме', animes_url(genre: '9-Ecchi')],
      ['Юри аниме', animes_url(genre: '34-Yuri')]
    ]
    @anime_misc_genres = [
      ['Аниме безумие', animes_url(genre: '5-Dementia')],
     #['Аниме гендерная интрига', animes_url(genre: '44-Gender-Bender')],
      ['Аниме комедия романтика', animes_url(genre: '4-Comedy,22-Romance')],
      ['Аниме комедия школа', animes_url(genre: '4-Comedy,23-School')],
      ['Аниме повседневность', animes_url(genre: '36-Slice-of-Life')],
      ['Аниме про полицию', animes_url(genre: '39-Police')],
      ['Аниме про сверхспособности', animes_url(genre: '31-Super-Power')],
      ['Аниме сёдзё комедия', animes_url(genre: '25-Shoujo,4-Comedy')],
      ['Аниме сёдзё школа', animes_url(genre: '25-Shoujo,23-School')],
      ['Аниме школа романтика', animes_url(genre: '23-School,22-Romance')],
      ['Аниме экшен', animes_url(genre: '1-Action')],
      ['Аниме про машины', animes_url(genre: '3-Cars')],
      ['Аниме жанра игры', animes_url(genre: '11-Game')],
      ['Аниме жанра музыка', animes_url(genre: '19-Music')],
      ['Аниме с оружием', animes_url(genre: '38-Military')],
      ['Дзёсэй аниме', animes_url(genre: '43-Josei')],
      ['Историческое аниме', animes_url(genre: '13-Historical')],
      ['Психологическое аниме', animes_url(genre: '40-Psychological')],
      ['Сёдзё-Ай аниме', animes_url(genre: '26-Shoujo-Ai')],
      ['Триллер аниме', animes_url(genre: '41-Thriller')]
    ]
    @manga_sections = [
      ['Каталог манги', mangas_url]
    ]
    @sections = [
      ['Аниме студии', studios_url],
      ['График онгоингов', ongoings_url],
      ['Аниме форум', section_url(:a)],
      #['Форум', forums_url],
      #['Блоги', blogs_url],
      ['Клубы', groups_url],
      ['Рецензии и обзоры', section_url(:reviews)],
      ['Турниры и голосования', contests_url],
      ['Новости', section_url(:news)]
    ]

    if params[:format] == 'xml'
      File.open('public/sitemap.xml', 'w') {|v| v.write(render_to_string 'index.xml.builder') }
      redirect_to sitemap_url(format: :xml)
    end
  end
end
