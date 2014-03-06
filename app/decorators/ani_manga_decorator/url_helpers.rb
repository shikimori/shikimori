module AniMangaDecorator::UrlHelpers
  # адрес аниме
  def url
    if anime?
      h.anime_url object
    else
      h.manga_url object
    end
  end

  def page_url page
    h.send "page_#{klass_lower}_url", object, page: page
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

  # адрес добавления в список
  def rate_url
    h.send "rate_#{klass_lower}_url", object
  end

  # адрес редактирования
  def edit_url page
    h.send "edit_#{klass_lower}_url", object, subpage: page
  end

  # адрес связанных аниме
  def related_url
    h.send "related_all_#{klass_lower}_url"
  end

  # адрес на mal'е
  def mal_url
    "http://myanimelist.net/#{klass_lower}/#{object.id}"
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

