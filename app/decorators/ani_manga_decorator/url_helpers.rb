module AniMangaDecorator::UrlHelpers
  # адрес аниме
  def url
    if anime?
      h.anime_url object
    else
      h.manga_url object
    end
  end

  def stats_url
    h.send "stats_#{klass_lower}_url", object
  end

  def characters_url
    h.send "characters_#{klass_lower}_url", object
  end

  def staff_url
    h.send "staff_#{klass_lower}_url", object
  end

  def recent_url
    h.send "recent_#{klass_lower}_url", object
  end

  def similar_url
    h.send "similar_#{klass_lower}_url", object
  end

  def screenshots_url
    h.send "screenshots_#{klass_lower}_url", object
  end

  def videos_url
    h.send "videos_#{klass_lower}_url", object
  end

  def images_url
    h.send "images_#{klass_lower}_url", object
  end

  def chronology_url
    h.send "chronology_#{klass_lower}_url", object
  end

  def files_url
    h.send "files_#{klass_lower}_url", object
  end

  # адрес косплея персонажа
  def cosplay_url character, gallery = nil
    if gallery
      h.send "cosplay_#{klass_lower}_url", object, character, gallery
    else
      h.send "cosplay_#{klass_lower}_url", object, character
    end
  end

  # адрес обзоров
  def reviews_url
    h.send "#{klass_lower}_reviews_url", object
  end

  # адрес создания обзора
  def new_review_url
    h.send "new_#{klass_lower}_review_url", object
  end

  # адрес редактирования
  def edit_url page
    h.send "edit_#{klass_lower}_url", object, subpage: page
  end

  # адрес связанных аниме
  def related_url
    h.send "related_#{klass_lower}_url"
  end

  # адрес ресурсов аниме
  def resources_url
    h.send "resources_#{klass_lower}_url"
  end

  # адрес на mal'е
  def mal_url
    "http://myanimelist.net/#{klass_lower}/#{object.id}"
  end

  def other_names_url
    h.send "other_names_#{klass_lower}_url", object
  end

  # урл страницы с отзывами
  def comments_reviews_url
    h.model_comments_path commentable_type: thread.class.name.underscore, commentable_id: thread.id, offset: 0, limit: 15, review: 'review'
  end

  # урл страницы со всеми комментариями
  def comments_all_url
    h.model_comments_path commentable_type: thread.class.name.underscore, commentable_id: thread.id, offset: 0, limit: 15
  end
end

