class Clubs::Query < QueryObjectBase
  FAVOURED_IDS = [72, 19, 315, 903, 912, 2046]
  SEARCH_LIMIT = 999

  def self.fetch locale
    new Club
      .joins(:topics)
      .preload(:owner, :topics)
      .where(locale: locale)
      .order(Arel.sql('topics.updated_at desc, id'))
  end

  def favourites
    chain @scope.where(id: FAVOURED_IDS)
  end

  def without_favourites
    chain @scope.where.not(id: FAVOURED_IDS)
  end

  def search phrase, locale
    return self if phrase.blank?

    chain Search::Club.call(
      scope: @scope,
      phrase: phrase,
      locale: locale,
      ids_limit: SEARCH_LIMIT
    )
  end
end
