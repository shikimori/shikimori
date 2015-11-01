class DashboardView < ViewObjectBase
  ONGOINGS_FETCH = 24
  ONGOINGS_TAKE = 8

  TOPICS_FETCH = 10
  TOPICS_TAKE = 1

  instance_cache :ongoings, :favourites, :reviews
  #preload :all_ongoings, :all_favourites

  def ongoings
    ApplyRatedEntries.new(h.current_user).call(
      all_ongoings.take(ONGOINGS_TAKE).sort_by(&:ranked)
    )
  end

  def seasons
    Menus::TopMenu.new.seasons.select do |year, _, _|
      year.to_i != Time.zone.now.year + 1 &&
        year.to_i != Time.zone.now.year - 1
    end
  end

  def reviews
    all_reviews
      .take(TOPICS_TAKE)
      .sort_by { |topic| -topic.id }
      .map { |topic| Topics::ReviewView.new topic, true, true }
  end

  #def favourites
    #all_favourites.take(ONGOINGS_TAKE / 2).sort_by(&:ranked)
  #end

private

  def all_ongoings
    OngoingsQuery.new(false)
      .fetch(ONGOINGS_FETCH)
      .decorate
      .shuffle
  end

  def all_reviews
    topics = TopicsQuery
      .new(reviews_section, h.current_user, nil)
      .fetch(1, TOPICS_FETCH)
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
