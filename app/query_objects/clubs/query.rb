class Clubs::Query < QueryObjectBase
  FAVOURED_IDS = [72, 315, 2046]
  SEARCH_LIMIT = 999

  def self.fetch user, is_skip_restrictions, initial_scope = Club
    scope = new initial_scope
      .joins(:topic)
      .preload(:owner, :topic)
      .order(Arel.sql('topics.updated_at desc, id'))

    return scope if is_skip_restrictions

    if user
      scope
        .without_shadowbanned(user)
    else
      scope
        .without_censored
        .without_shadowbanned
        .without_private
    end
  end

  def favourites
    chain @scope.where(id: FAVOURED_IDS)
  end

  def without_favourites
    chain @scope.where.not(id: FAVOURED_IDS)
  end

  def without_censored
    chain @scope.where(is_censored: false)
  end

  def without_private
    chain @scope.where(is_private: false)
  end

  def without_shadowbanned decorated_user = nil
    chain(
      decorated_user ?
        @scope.where(
          'is_shadowbanned = false or clubs.id in (?)',
          decorated_user.club_ids
        ) :
        @scope.where(is_shadowbanned: false)
    )
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
