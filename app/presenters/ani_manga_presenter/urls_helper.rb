module AniMangaPresenter::UrlsHelper
  # адрес аниме
  def url#(params={})
    if anime?
      anime_url entry#, params
    else
      manga_url entry#, params
    end
  end

  def page_url(page)
    send "page_#{klass_lower}_url", entry, page: page
  end

  # адрес косплея персонажа
  def cosplay_url(character)
    send "cosplay_#{klass_lower}_url", entry, character
  end

  # адрес обзоров
  def reviews_url
    send "#{klass_lower}_reviews_url", entry
  end

  # адрес создания обзора
  def new_review_url
    send "new_#{klass_lower}_review_url", entry
  end

  # адрес добавления в список
  def rate_url
    send "rate_#{klass_lower}_url", entry
  end

  # адрес редактирования
  def edit_url(page)
    send "edit_#{klass_lower}_url", entry, subpage: page
  end

  # адрес связанных аниме
  def related_url
    send "related_all_#{klass_lower}_url"
  end

  # адрес на mal'е
  def mal_url
    "http://myanimelist.net/#{klass_lower}/#{entry.id}"
  end

  # урл страницы с отзывами
  def comments_reviews_url
    model_comments_path commentable_type: thread.class.name.underscore, commentable_id: thread.id, offset: 0, limit: 15, review: 'review'
  end

  # урл страницы со всеми комментариями
  def comments_all_url
    model_comments_path commentable_type: thread.class.name.underscore, commentable_id: thread.id, offset: 0, limit: 15
  end
end
