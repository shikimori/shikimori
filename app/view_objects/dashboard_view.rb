class DashboardView < ViewObjectBase
  FETCH_LIMIT = 24
  TAKE_LIMIT = 8

  instance_cache :ongoings, :favourites
  #preload :all_ongoings, :all_favourites

  def ongoings
    ApplyRatedEntries.new(h.current_user).call(
      all_ongoings.take(TAKE_LIMIT).sort_by(&:ranked)
    )
  end

  def favourites
    all_favourites.take(TAKE_LIMIT / 2).sort_by(&:ranked)
  end

private

  def all_ongoings
    OngoingsQuery.new(false)
      .fetch(FETCH_LIMIT)
      .decorate
      .shuffle
  end

  def all_favourites
    Anime
      .where(id: FavouritesQuery.new.top_favourite_ids(Anime, FETCH_LIMIT))
      .decorate
      .shuffle
  end
end
