class People::Query < QueryObjectBase
  SEARCH_LIMIT = 999

  def self.fetch is_producer:, is_mangaka:, is_seyu:
    scope = Person.order(:id)

    scope.where! is_producer: is_producer unless is_producer.nil?
    scope.where! is_mangaka: is_mangaka unless is_mangaka.nil?
    scope.where! is_seyu: is_seyu unless is_seyu.nil?

    new scope
  end

  def search phrase, is_producer: nil, is_mangaka: nil, is_seyu: nil
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

  def by_id id
    return self if id.blank?

    chain @scope.where(id: id)
  end
end
