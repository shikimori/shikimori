class Collections::Query < QueryObjectBase
  SEARCH_LIMIT = 999

  def self.fetch
    new Collection
      .available
      .includes(:topics)
      .order(id: :desc)
  end

  def search phrase
    return self if phrase.blank?

    chain Search::Collection.call(
      scope: @scope,
      phrase: phrase,
      ids_limit: SEARCH_LIMIT
    )
  end
end
