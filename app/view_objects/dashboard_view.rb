class DashboardView < ViewObjectBase
  ONGOINGS_FETCH = 24
  ONGOINGS_TAKE = 8

  TOPICS_FETCH = 3
  TOPICS_TAKE = 1

  DISPLAYED_HISTORY = 2

  instance_cache :ongoings, :favourites, :reviews, :contests
  #preload :all_ongoings, :all_favourites

  def ongoings
    ApplyRatedEntries.new(h.current_user).call(
      all_ongoings
        .shuffle.take(ONGOINGS_TAKE).sort_by(&:ranked)
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
      .shuffle.take(TOPICS_TAKE).sort_by { |view| -view.topic.id }
  end

  def user_news
    TopicsQuery.new(h.current_user)
      .by_section(Section.static[:news])
      .where(generated: false)
      .order!(created_at: :desc)
      .limit(5)
      .as_views(true, true)
  end

  def generated_news
    TopicsQuery.new(h.current_user)
      .by_section(Section.static[:news])
      .where(generated: true)
      .order!(created_at: :desc)
      .limit(8)
      .as_views(true, true)
  end

  #def favourites
    #all_favourites.take(ONGOINGS_TAKE / 2).sort_by(&:ranked)
  #end

  def contests
    Contest.current
  end

  def list_counts kind
    h.current_user.stats.list_counts kind
  end

  def history
    h.current_user.history.formatted.take DISPLAYED_HISTORY
  end

private

  def all_ongoings
    this_season = AnimeSeasonQuery.new(SeasonPair.new(Time.zone.today).to_s, Anime).to_sql
    prior_season = AnimeSeasonQuery.new(SeasonPair.new(3.month.ago).to_s, Anime).to_sql

    OngoingsQuery.new(false)
      .fetch(ONGOINGS_FETCH)
      .where("(#{this_season}) OR (#{prior_season})")
      .where('score > 7.5')
      .decorate
  end

  def all_reviews
    TopicsQuery.new(h.current_user)
      .by_section(reviews_section)
      .limit(TOPICS_FETCH)
      .as_views(true, true)
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
