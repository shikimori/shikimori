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

  def seasons
    TopMenu.new.seasons
  end

  def reviews
    all_reviews.sort_by { |v| v.topic.created_at }.reverse().take(4)
  end

  #def favourites
    #all_favourites.take(TAKE_LIMIT / 2).sort_by(&:ranked)
  #end

private

  def all_ongoings
    OngoingsQuery.new(false)
      .fetch(FETCH_LIMIT)
      .decorate
      .shuffle
  end

  def all_reviews
    topics = TopicsQuery
      .new(reviews_section, h.current_user, nil)
      .fetch(1, 12)
      .map { |v| Topics::Preview.new v }
      .shuffle
  end

  #def all_favourites
    #Anime
      #.where(id: FavouritesQuery.new.top_favourite_ids(Anime, FETCH_LIMIT))
      #.decorate
      #.shuffle
  #end

  def reviews_section
    Section.find_by_permalink('reviews')
  end
end
