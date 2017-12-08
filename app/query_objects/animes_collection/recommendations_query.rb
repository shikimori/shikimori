class AnimesCollection::RecommendationsQuery < AnimesCollection::PageQuery
  method_object %i[klass! filters! user limit! ranked_ids!]

private

  def process query
    from = limit * (page - 1)
    to = from + limit - 1

    query[from..to] || []
  end

  def query
    binding.pry
    return [] if @ranked_ids.blank?
    @query ||= super.sort_by { |entry| @ranked_ids.index entry.id }
  end

  def filters
    super.merge(
      AniMangaQuery::EXCLUDE_AI_GENRES_KEY => true,
      AniMangaQuery::IDS_KEY => ranked_ids
    )
  end
end
