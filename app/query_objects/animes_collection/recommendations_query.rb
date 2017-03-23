class AnimesCollection::RecommendationsQuery < AnimesCollection::PageQuery
private

  def process query
    from = limit * (page - 1)
    to = from + limit - 1

    query[from..to]
  end

  def query
    super.sort_by { |entry| params[AniMangaQuery::IDS_KEY].index entry.id }
  end

  def params
    super.merge AniMangaQuery::EXCLUDE_AI_GENRES_KEY => true
  end
end
