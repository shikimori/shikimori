class MangaDecorator < AniMangaDecorator
  def screenshots limit=nil
    []
  end

  def videos limit=nil
    []
  end

  # тип элемента для schema.org
  def itemtype
    'http://schema.org/CreativeWork'
  end
end
