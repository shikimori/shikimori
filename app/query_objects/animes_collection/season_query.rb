class AnimesCollection::SeasonQuery < AnimesCollection::PageQuery
  def page
    1
  end

  def pages_count
    1
  end
end
