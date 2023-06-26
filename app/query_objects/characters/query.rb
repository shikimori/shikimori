class Characters::Query < QueryObjectBase
  SEARCH_LIMIT = 999

  def self.fetch
    new Character.order(:id)
  end

  def search phrase
    return self if phrase.blank?

    chain Search::Character.call(
      scope: @scope,
      phrase: phrase,
      ids_limit: SEARCH_LIMIT
    )
  end

  def by_desynced value, user
    return self if value.blank? || !user&.staff?

    chain Animes::Filters::ByDesynced.call(@scope, value)
  end
end
