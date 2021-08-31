class MangaDecorator < AniMangaDecorator
  def censored_in_russia?
    false
  end

  def news_topic_views
    return [] if rkn_abused?

    []
  end

  def screenshots _limit = nil
    []
  end

  def videos _limit = nil
    []
  end

  def menu_external_links
    if h.user_signed_in? && h.current_user.week_registered? && Copyright::MANGA_IDS.exclude?(id)
      available_external_links
    else
      available_external_links.reject(&:read_online?)
    end
  end

  # тип элемента для schema.org
  def itemtype
    'http://schema.org/CreativeWork'
  end
end
