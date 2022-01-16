class Forum < ApplicationRecord
  has_many :topics, dependent: :destroy

  validates :permalink, presence: true

  # разделы, в которые можно создавать топики из интерфейса
  PUBLIC_SECTIONS = %w[animanga site games vn contests offtopic]
  VARIANTS = PUBLIC_SECTIONS + %w[
    clubs my_clubs critiques news collections articles cosplay
  ]

  ANIME_NEWS_ID = 1
  SITE_ID = 4
  OFFTOPIC_ID = 8
  CLUBS_ID = 10
  CONTESTS_ID = 13
  COLLECTIONS_ID = 14
  COSPLAY_ID = 15
  NEWS_ID = 20
  CRITIQUES_ID = 12
  REVIEWS_ID = 24
  ARTICLES_ID = 21
  PREMODERATION_ID = 22
  HIDDEN_ID = 23

  UPDATES_FORUM = FakeForum.new 'updates', 'Обновления аниме', 'Anime updates'
  MY_CLUBS_FORUM = FakeForum.new 'my_clubs', 'Мои клубы', 'My clubs'

  def to_param
    permalink
  end

  def name
    I18n.russian? ? name_ru : name_en
  end

  class << self
    def public
      cached.select { |v| PUBLIC_SECTIONS.include? v.permalink }
    end

    # rubocop:disable Rails/DynamicFindBy
    def news
      find_by_permalink 'news'
    end

    def critiques
      find_by_permalink 'critiques'
    end

    def articles
      find_by_permalink 'articles'
    end

    def collections
      find_by_permalink 'collections'
    end

    def hidden
      find_by_permalink 'hidden'
    end
    # rubocop:enable Rails/DynamicFindBy

    def find_by_permalink permalink
      cached_plus_special.find do |forum|
        forum.permalink == permalink
      end
    end

    def cached
      @cached ||= all.to_a.sort_by(&:position)
    end

    def cached_plus_special
      @cached_plus_special ||= cached + [UPDATES_FORUM, MY_CLUBS_FORUM]
    end
  end
end
