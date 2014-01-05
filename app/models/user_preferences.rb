# настройки профиля пользователя
class UserPreferences < ActiveRecord::Base
  DefaultSort = 'name'

  belongs_to :user, touch: true

  def anime_in_profile?
    anime_in_profile
  end

  def manga_in_profile?
    manga_in_profile
  end

  def clubs_in_profile?
    clubs_in_profile
  end

  def comments_in_profile?
    comments_in_profile
  end

  def manga_first?
    manga_first
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

  def statistics_in_profile?
    statistics_in_profile
  end

  def mylist_in_catalog?
    mylist_in_catalog
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

  def update_sorting(order)
    update_attribute(:default_sort, order) if default_sort != order
  end
end
