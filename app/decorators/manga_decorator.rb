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

  # тип элемента для schema.org
  def itemtype
    'http://schema.org/CreativeWork'
  end
end
