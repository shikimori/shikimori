class AnimesCollection::RecommendationsQuery < AnimesCollection::PageQuery
  IDS_KEY = :ids
  EXCLUDE_IDS_KEY = :exclude_ids

private

  def process query
    from = limit * (page-1)
    to = from + limit - 1

    query[from..to]
  end

  def query
    super
      .where(id: params[IDS_KEY])
      .sort_by { |v| params[IDS_KEY].index v.id }
  end

  def params
    super.merge AniMangaQuery::EXCLUDE_AI_GENRES_KEY => true
  end
end
