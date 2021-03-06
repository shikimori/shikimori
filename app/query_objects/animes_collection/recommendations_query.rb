class AnimesCollection::RecommendationsQuery < AnimesCollection::PageQuery
  method_object %i[klass! filters! user limit! ranked_ids!]

private

  def process query
    from = limit * (page - 1)
    to = from + limit - 1

    query[from..to] || []
  end

  def query
    return [] if @ranked_ids.blank?

    @query ||= super
      .by_ids(ranked_ids)
      .exclude_ai_genres(@user&.sex)
      .sort_by { |entry| @ranked_ids.index entry.id }
  end
end
