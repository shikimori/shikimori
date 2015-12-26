class Forum < ActiveRecord::Base
  has_many :topics, dependent: :destroy

  validates :permalink, presence: true

  VARIANTS = /animanga|site|offtopic|clubs|reviews|contests|news/
  # разделы, в которые можно создавать топики из интерфейса
  PUBLIC_SECTIONS = %w{ offtopic animanga site games vn }

  ANIME_NEWS_ID = 1
  CLUBS_ID = 10
  OFFTOPIC_ID = 8
  CONTESTS_ID = 13
  COSPLAY_ID = 15

  NEWS_FORUM = FakeForum.new 'news', 'Лента новостей'
  UPDATES_FORUM = FakeForum.new 'updates', 'Обновления аниме'
  MY_CLUBS_FORUM = FakeForum.new 'my_clubs', 'Мои клубы'

  def to_param
    permalink
  end

  class << self
    def public
      cached
        .select { |v| PUBLIC_SECTIONS.include? v.permalink }
        .sort_by { |v| PUBLIC_SECTIONS.index v.permalink }
    end

    def visible
      cached.select(&:is_visible).sort_by(&:position)
    end

    def find_by_permalink permalink
      (cached + [NEWS_FORUM, UPDATES_FORUM, MY_CLUBS_FORUM]).find do |forum|
        forum.permalink == permalink
      end
    end

    def cached
      @cached ||= all.to_a.sort_by(&:position)
    end
  end
end
