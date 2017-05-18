class AnimesCollection::RecommendationsQuery < AnimesCollection::PageQuery
private

  def process query
    from = limit * (page - 1)
    to = from + limit - 1

    query[from..to]
  end

  def query
    return [] if params[AniMangaQuery::IDS_KEY].blank?

    @query ||= super.sort_by do |entry|
      params[AniMangaQuery::IDS_KEY].index entry.id
    end
  end

  def params
    super.merge AniMangaQuery::EXCLUDE_AI_GENRES_KEY => true
  end
end
