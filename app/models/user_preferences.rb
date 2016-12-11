class UserPreferences < ActiveRecord::Base
  belongs_to :user, touch: true

  enumerize :list_privacy,
    in: [:public, :users, :friends, :owner],
    predicates: { prefix: true },
    default: :public
  enumerize :body_width, in: [:x1200, :x1000], default: :x1200
  enumerize :comment_policy,
    in: [:users, :friends, :owner],
    predicates: { prefix: true },
    default: :users

  boolean_attribute :comments_auto_collapsed
  boolean_attribute :comments_auto_loaded

  validates :default_sort,
    length: { maximum: 255 },
    allow_blank: true

  before_create :set_forums unless Rails.env.test?

  def default_sort
    super || (russian_names? ? 'russian' : 'name')
  end

  def anime_in_profile?
    anime_in_profile
  end

  def manga_in_profile?
    manga_in_profile
  end

  def comments_in_profile?
    comments_in_profile
  end

  def russian_names?
    russian_names
  end

  def russian_genres?
    russian_genres
  end

  def about_on_top?
    about_on_top
  end

  def menu_contest?
    menu_contest
  end

  def show_smileys?
    show_smileys
  end

  def show_social_buttons?
    show_social_buttons
  end

  def show_hentai_images?
    show_hentai_images
  end

  def volumes_in_manga?
    volumes_in_manga
  end

  # TODO: выпилить это поле из базы и из кода
  def postload_in_catalog?
    postload_in_catalog
  end

private

  def set_forums
    self.forums = Forums::List.defaults
  end
end
