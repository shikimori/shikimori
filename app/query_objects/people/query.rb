class People::Query < QueryObjectBase
  SEARCH_LIMIT = 999

  def self.fetch is_producer:, is_mangaka:, is_seyu:
    scope = Person.order(:id)

    scope.where! is_producer: is_producer if is_producer
    scope.where! is_mangaka: is_mangaka if is_mangaka
    scope.where! is_seyu: is_seyu if is_seyu

    new scope
  end

  def search phrase, is_producer:, is_mangaka:, is_seyu:
    return self if phrase.blank?

    chain Search::Person.call(
      scope: @scope,
      phrase: phrase,
      is_producer: is_producer,
      is_mangaka: is_mangaka,
      is_seyu: is_seyu,
      ids_limit: SEARCH_LIMIT
    )
  end

  def by_desynced value, user
    return self if value.blank? || !user&.staff?

    chain Animes::Filters::ByDesynced.call(@scope, value)
  end
end
