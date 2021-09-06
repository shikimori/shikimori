module AniMangaDecorator::UrlHelpers
  def tooltip_url minified = false
    h.send "tooltip_#{klass_lower}_url", object,
      minified: minified ? :minified : nil
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
    h.send "favoured_#{klass_lower}_url", object
  end

  def clubs_url
    h.send "clubs_#{klass_lower}_url", object
  end

  def coub_url
    h.send "coub_#{klass_lower}_url", object
  end

  def collections_url page: nil
    h.send(
      "collections_#{klass_lower}_url",
      object,
      page: page
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
      params
    )
  end

  # def summaries_url
  #   h.send(
  #     "#{klass_lower.pluralize}_summaries_url",
  #     params
  #   )
  # end

  def summary_url summary
    h.send(
      "#{klass_lower}_summary_url",
      object,
      summary
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
end
