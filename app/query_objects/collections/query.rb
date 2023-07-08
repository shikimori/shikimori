class Collections::Query < QueryObjectBase
  SEARCH_LIMIT = 999

  def self.fetch is_censored_forbidden
    scope = Collection
      .available
      .includes(:topic)
      .order(id: :desc)

    new(
      is_censored_forbidden ?
        scope.where(is_censored: false) :
        scope
    )
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
