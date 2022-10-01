class Articles::Query < QueryObjectBase
  SEARCH_LIMIT = 999

  def self.fetch
    new Article
      .available
      .includes(:topic)
      .order(id: :desc)
  end

  def search phrase
    return self if phrase.blank?

    chain Search::Article.call(
      scope: @scope,
      phrase: phrase,
      ids_limit: SEARCH_LIMIT
    )
  end
end
