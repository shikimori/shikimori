class MangaDecorator < AniMangaDecorator
  def news_topic_views
    []
  end

  def screenshots limit=nil
    []
  end

  def videos limit=nil
    []
  end

  def licensed?
    true
  end

  # тип элемента для schema.org
  def itemtype
    'http://schema.org/CreativeWork'
  end
end
