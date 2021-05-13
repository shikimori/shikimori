class MangaDecorator < AniMangaDecorator
  def news_topic_views
    []
  end

  def screenshots _limit = nil
    []
  end

  def videos _limit = nil
    []
  end

  def menu_external_links
    if h.user_signed_in? && h.current_user.week_registered?
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
