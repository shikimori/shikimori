# настройки профиля пользователя
class ProfileSettings < ActiveRecord::Base
  DefaultSort = 'name'

  belongs_to :user

  def anime?
    anime
  end

  def anime_genres?
    anime_genres
  end

  def anime_studios?
    anime_studios
  end

  def manga?
    manga
  end

  def magna_genres?
    manga_genres
  end

  def manga_publishers?
    manga_publishers
  end

  def genres_graph?
    genres_graph
  end

  def clubs?
    clubs
  end

  def comments?
    comments
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

  def statistics?
    statistics
  end

  def mylist_in_catalog?
    mylist_in_catalog
  end

  def menu_contest?
    menu_contest
  end

  def update_sorting(order)
    update_attribute(:default_sort, order) if default_sort != order
  end
end
