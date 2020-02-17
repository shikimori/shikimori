class UserPreferences < ApplicationRecord
  belongs_to :user, touch: true

  enumerize :list_privacy,
    in: %i[public users friends owner],
    predicates: { prefix: true },
    default: :public
  enumerize :body_width,
    in: %i[x1200 x1000],
    predicates: { prefix: true },
    default: :x1200
  enumerize :dashboard_type,
    in: %i[new old],
    predicates: { prefix: true },
    default: :new
  enumerize :comment_policy,
    in: %i[users friends owner],
    predicates: { prefix: true },
    default: :users
  enumerize :default_sort,
    in: Animes::Filters::OrderBy::Field.values

  boolean_attribute :comments_auto_collapsed
  boolean_attribute :comments_auto_loaded

  validates :default_sort,
    length: { maximum: 255 },
    allow_blank: true

  validates :favorites_in_profile, numericality: { greater_than_or_equal_to: 0 }

  before_create :set_forums unless Rails.env.test?

  def default_sort
    super || (
      russian_names? ?
        Animes::Filters::OrderBy::Field[:russian] :
        Animes::Filters::OrderBy::Field[:name]
    )
  end

  %i[
    anime_in_profile
    manga_in_profile
    comments_in_profile
    achievements_in_profile
    russian_names
    russian_genres
    about_on_top
    show_smileys
    show_social_buttons
    show_hentai_images
    volumes_in_manga
  ].each do |name|
    define_method :"#{name}?" do
      send name
    end
  end

  # TODO: remove it
  def postload_in_catalog?
    postload_in_catalog
  end

private

  def set_forums
    self.forums = Forums::List.new(with_forum_size: false).map(&:id) -
      [Forum.find_by_permalink('clubs').id]
  end
end
