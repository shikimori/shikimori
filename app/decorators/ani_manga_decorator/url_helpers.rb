module AniMangaDecorator::UrlHelpers
  def tooltip_url minified = false
    h.send "tooltip_#{klass_lower}_url", object,
      minified: minified ? :minified : nil,
      subdomain: false
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

  def franchise_url
    h.send "franchise_#{klass_lower}_url", object
  end

  def chronology_url
    h.send "chronology_#{klass_lower}_url", object
  end

  def related_url
    h.send "related_#{klass_lower}_url"
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

  def coub_url
    h.send "coub_#{klass_lower}_url", object, subdomain: false
  end

  def collections_url page: nil
    h.send(
      "collections_#{klass_lower}_url",
      object,
      page: page,
      subdomain: false
    )
  end

  def cosplay_url page = 1
    if page > 1
      h.send "cosplay_#{klass_lower}_url", object, page: page
    else
      h.send "cosplay_#{klass_lower}_url", object
    end
  end

  def files_url
    h.send "files_#{klass_lower}_url", object
  end

  def collection_url params = {}
    h.send(
      "#{klass_lower.pluralize}_collection_url",
      params.merge(subdomain: false)
    )
  end

  # адрес косплея персонажа
  # def cosplay_url character, gallery = nil
  #   if gallery
  #     h.send "cosplay_#{klass_lower}_url", object, character, gallery
  #   else
  #     h.send "cosplay_#{klass_lower}_url", object, character
  #   end
  # end

  def reviews_url
    h.send "#{klass_lower}_reviews_url", object
  end

  def new_review_url
    h.send "new_#{klass_lower}_review_url", object,
      'review[user_id]' => h.current_user&.id,
      'review[target_id]' => id,
      'review[target_type]' => object.class.name
  end

  def resources_url
    h.send "resources_#{klass_lower}_url"
  end

  def other_names_url
    h.send "other_names_#{klass_lower}_url", object
  end

  def summaries_url
    h.send "summaries_#{klass_lower}_url", object
  end

  def video_online_url
    h.play_video_online_index_url object,
      episode: 1, domain: AnimeOnlineDomain::HOST, subdomain: false
  end

  def upload_first_video_online_url
    h.new_video_online_url(
      object,
      'anime_video[anime_id]' => id,
      'anime_video[source]' => Shikimori::DOMAIN,
      'anime_video[state]' => 'uploaded',
      'anime_video[kind]' => 'fandub',
      'anime_video[episode]' => 1,
      domain: AnimeOnlineDomain::HOST,
      subdomain: false
    )
  end
end
