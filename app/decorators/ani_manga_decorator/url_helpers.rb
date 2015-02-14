module AniMangaDecorator::UrlHelpers
  # адрес аниме
  def url subdomain=true
    if anime?
      h.anime_url object, subdomain: subdomain
    else
      h.manga_url object, subdomain: subdomain
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

  def art_url
    h.send "art_#{klass_lower}_url", object
  end

  def favoured_url
    h.send "favoured_#{klass_lower}_url", object, subdomain: false
  end

  def clubs_url
    h.send "clubs_#{klass_lower}_url", object, subdomain: false
  end

  #def cosplay_url
    #h.send "cosplay_#{klass_lower}_url", object
  #end

  def files_url
    h.send "files_#{klass_lower}_url", object
  end

  def catalog_url *args
    h.send "#{klass_lower}s_url", *args
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
    h.send "new_#{klass_lower}_review_url", object,
      'review[user_id]' => h.current_user.id,
      'review[target_id]' => id, 'review[target_type]' => object.class.name
  end

  # адрес редактирования
  def edit_url page=nil
    h.send "edit_#{klass_lower}_url", object, page: page
  end

  # адрес связанных аниме
  def related_url
    h.send "related_#{klass_lower}_url"
  end

  # адрес ресурсов аниме
  def resources_url
    h.send "resources_#{klass_lower}_url"
  end

  def other_names_url
    h.send "other_names_#{klass_lower}_url", object
  end

  # урл страницы с отзывами
  def comments_reviews_url
    h.send "reviews_#{klass_lower}_url", object
  end

  # урл страницы со всеми комментариями
  def comments_all_url
    h.send "comments_#{klass_lower}_url", object
  end

  def video_online_url
    h.play_video_online_index_url object, episode: 1, domain: AnimeOnlineDomain::HOST, subdomain: false
  end

  def upload_first_video_online_url
    h.new_video_online_url(object,
      'anime_video[anime_id]' => id,
      'anime_video[source]' => Site::DOMAIN,
      'anime_video[state]' => 'uploaded',
      'anime_video[kind]' => 'fandub',
      'anime_video[episode]' => 1,
      domain: AnimeOnlineDomain::HOST,
      subdomain: false
    )
  end
end
