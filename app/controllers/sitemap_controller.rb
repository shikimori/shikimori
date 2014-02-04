class SitemapController < ApplicationController
  def index
    if params[:format] == 'xml'
      @animes = Anime.where { description.not_eq('') | description.not_eq(nil) }
                     .where { source.eq('') | source.eq(nil) }
                     .where.not(kind: 'Special')
                     .order(updated_at: :desc)
      @mangas = Manga.where { description.not_eq('') | description.not_eq(nil) }
                     .where { source.eq('') | source.eq(nil) }
                     .order(updated_at: :desc)
    end

    @page_title = 'Карта сайта'
    @last_animepage_change = DateTime.parse('2011-06-05 15:12:43')

    @anime_sections = [
      #['Последние аниме', animes_url(season: 'latest')],
      ['Каталог аниме', animes_url],
      ['Аниме сериалы', animes_url(type: 'TV')],
      ['Полнометражные аниме', animes_url(type: 'Movie')],
      ['Аниме 2014 года', animes_url(season: 2014)],
      ['Аниме 2013 года', animes_url(season: 2013)],
      ['Аниме 2012 года', animes_url(season: 2012)],
      #['Аниме осени 2011 года', animes_url(season: 'fall_2011')],
      #['Аниме лета 2011 года', animes_url(season: 'summer_2011')],
      #['Аниме весны 2011 года', animes_url(season: 'spring_2011')],
      ['Аниме 2011 года', animes_url(season: 2011)],
      ['Аниме 2010 года', animes_url(season: 2010)],
      ['Аниме 2009 года', animes_url(season: 2009)],
      ['Аниме 2008 года', animes_url(season: 2008)]
    ]
    @anime_genres = [
      ['Аниме боевые искусства', animes_url(genre: '17-Martial-Arts')],
      ['Аниме драма', animes_url(genre: '8-Drama')],
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
      ['Аниме яой', animes_url(genre: '33-Yaoi')],
      ['Историческое аниме', animes_url(genre: '13-Historical')],
      ['Меха аниме', animes_url(genre: '18-Mecha')],
      ['Сверхъестественное аниме', animes_url(genre: '37-Supernatural')],
      ['Сёдзе Ай аниме', animes_url(genre: '26-Shoujo-Ai')],
      ['Сёдзе аниме', animes_url(genre: '25-Shoujo')],
      ['Сёнен аниме', animes_url(genre: '27-Shounen')],
      ['Сёнен Ай аниме', animes_url(genre: '28-Shounen-Ai')],
      ['Детское аниме', animes_url(genre: '15-Kids')],
      ['Триллер аниме', animes_url(genre: '41-Thriller')],
      ['Фэнтези аниме', animes_url(genre: '10-Fantasy')],
      ['Этти аниме', animes_url(genre: '9-Ecchi')],
      ['Юри аниме', animes_url(genre: '34-Yuri')]
    ]
    @anime_misc_genres = [
      ['Аниме безумие', animes_url(genre: '5-Dementia')],
      ['Аниме гарем', animes_url(genre: '35-Harem')],
      ['Аниме комедия романтика', animes_url(genre: '4-Comedy,22-Romance')],
      ['Аниме комедия школа', animes_url(genre: '4-Comedy,23-School')],
      ['Аниме повседневность', animes_url(genre: '36-Slice-of-Life')],
      ['Аниме про полицию', animes_url(genre: '39-Police')],
      ['Аниме седзе комедия', animes_url(genre: '25-Shoujo,4-Comedy')],
      ['Аниме седзе школа', animes_url(genre: '25-Shoujo,23-School')],
      ['Аниме школа романтика', animes_url(genre: '23-School,22-Romance')],
      ['Военное аниме', animes_url(genre: '38-Military')],
      ['Психологическое аниме', animes_url(genre: '40-Psychological')]
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
