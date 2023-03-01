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

  boolean_attributes :comments_auto_collapsed,
    :comments_auto_loaded,
    :show_age,
    :view_censored

  DEFAULT_FAVOURITES_TO_DISPLAY = 8

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

private

  def set_forums
    self.forums = Forums::List.new(with_forum_size: false).map(&:id) -
      [Forum.find_by_permalink('clubs').id] # rubocop:disable DynamicFindBy
  end
end
