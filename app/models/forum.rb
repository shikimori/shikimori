# TODO: если жалоб пользователей на удаление Feed не будет, то выпилить этот раздел с логикой подписок на топики совсем
class Forum < ActiveRecord::Base
  has_many :topics, dependent: :destroy

  before_create :set_permalink

  VARIANTS = /animanga|site|offtopic|g|reviews|v|news/
  # разделы, в которые можно создавать топики из интерфейса
  PUBLIC_SECTIONS = %w{ offtopic animanga site }

  ANIME_NEWS_ID = 1
  CLUBS_ID = 10
  OFFTOPIC_ID = 8
  CONTESTS_ID = 13
  COSPLAY_ID = 15

  def to_param
    permalink
  end

  # задание пермалинка, если он не был задан
  def set_permalink
    self.permalink = Russian.translit(self.name.gsub(/[^A-zА-я0-9]/, '-').gsub(/-+/, '-').sub(/-$|^-/, '')).downcase unless permalink
  end

  class << self
    def static
      @static ||= {
        # news: Forum.new(
          # position: 3,
          # name: 'Новости',
          # permalink: 'news',
          # description: 'Новости аниме и манги.',
          # meta_title: 'Новости аниме и манги',
          # meta_keywords: 'аниме, манга, новости, события',
          # meta_description: 'Новости аниме и манги на шикимори.',
          # is_visible: true
        # ),
        # all: Forum.new(
          # position: -2,
          # # name: 'Аниме и манга',
          # # description: 'Все активные топики сайта.',
          # permalink: 'all',
          # # meta_title: 'Энциклопедия аниме и манги',
          # # meta_keywords: 'аниме, манга, список, каталог, форум, обсуждения, отзывы, персонажи, герои, косплей, сайт, анимэ, anime, manga',
          # # meta_description: 'Шикимори - энциклопедия аниме и манги, площадка для дискуссий на анимешные темы.',
          # is_visible: false
        # ),
        # feed: Forum.new(
          # position: -3,
          # name: 'Лента',
          # description: 'Топики, где я участвую в обсуждении, или за которыми я слежу.',
          # permalink: 'f',
          # meta_title: 'Моя лента',
          # is_visible: true
        # )
      }
    end

    def public
      with_aggregated
        .select { |v| PUBLIC_SECTIONS.include? v.permalink }
        .sort_by { |v| PUBLIC_SECTIONS.index v.permalink }
    end

    def with_aggregated
      @with_aggregated ||= (static.values + real).sort_by(&:position)
    end

    def visible
      with_aggregated.select(&:is_visible).sort_by(&:position)
    end

    def real
      @real ||= all.to_a
    end

    def find_by_permalink permalink
      with_aggregated.find { |v| v.permalink == permalink }
    end
  end
end
