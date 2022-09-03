class Clubs::Query < QueryObjectBase
  FAVOURED_IDS = [72, 315, 2046]
  SEARCH_LIMIT = 999

  def self.fetch is_user_signed_in
    scope = new Club
      .joins(:topics)
      .preload(:owner, :topics)
      .order(Arel.sql('topics.updated_at desc, id'))

    if is_user_signed_in
      scope
    else
      scope.without_censored
    end
  end

  def favourites
    chain @scope.where(id: FAVOURED_IDS)
  end

  def without_favourites
    chain @scope.where.not(id: FAVOURED_IDS)
  end

  def without_censored
    chain @scope.where.not(is_censored: true)
  end

  def search phrase
    return self if phrase.blank?

    chain Search::Club.call(
      scope: @scope,
      phrase: phrase,
      ids_limit: SEARCH_LIMIT
    )
  end
end
