class DashboardView < ViewObjectBase
  ONGOINGS_FETCH = 24
  ONGOINGS_TAKE = 8

  REVIEWS_FETCH = 3
  REVIEWS_TAKE = 1

  NEWS_LIMIT = 7

  DISPLAYED_HISTORY = 2

  SPECIAL_PAGES = 2

  THIS_SEASON_SQL = AnimeSeasonQuery.new(
    Titles::SeasonTitle.new(Time.zone.now, :season_year, Anime).text,
    Anime
  ).to_sql

  PRIOR_SEASON_SQL = AnimeSeasonQuery.new(
    Titles::SeasonTitle.new(3.month.ago, :season_year, Anime).text,
    Anime
  ).to_sql

  IGNORE_ONGOINGS = [31592]

  instance_cache :ongoings, :favourites, :reviews, :contests, :forums,
    :new_ongoings, :old_ongoings

  def ongoings
    ApplyRatedEntries.new(h.current_user).call(
      all_ongoings
        .shuffle.take(ONGOINGS_TAKE).sort_by(&:ranked)
    )
  end

  def db_seasons klass
    [
      Titles::StatusTitle.new(:ongoing, klass),
      Titles::SeasonTitle.new(3.months.from_now, :season_year, klass),
      Titles::SeasonTitle.new(Time.zone.now, :season_year, klass),
      Titles::SeasonTitle.new(3.months.ago, :season_year, klass),
      Titles::SeasonTitle.new(6.months.ago, :season_year, klass)
    ]
  end

  def manga_kinds
    Manga.kind.values.map { |kind| Titles::KindTitle.new kind, Manga }
  end

  def db_others klass
    month = Time.zone.now.beginning_of_month
    # + 1.month since 12th month belongs to the next year in Titles::SeasonTitle
    is_still_this_year = (month + 2.months + 1.month).year == month.year

    [
      Titles::StatusTitle.new(:anons, klass),
      (Titles::StatusTitle.new(:ongoing, klass) if klass == Manga),
      Titles::SeasonTitle.new(month + 2.months, :year, klass),
      Titles::SeasonTitle.new(is_still_this_year ? 1.year.ago : 2.months.ago, :year, klass),
      Titles::SeasonTitle.new(is_still_this_year ? 2.years.ago : 14.months.ago, :year, klass),
    ].compact
  end

  def reviews
    all_reviews
      .shuffle.take(REVIEWS_TAKE).sort_by { |view| -view.topic.id }
  end

  def news_topics
    TopicsQuery.new(h.current_user, h.censored_forbidden?)
      .by_forum(Forum::NEWS_FORUM)
      .limit(7)
      .paginate(page, NEWS_LIMIT)
      .as_views(true, true)
      .result
  end

  def generated_news
    TopicsQuery.new(h.current_user, h.censored_forbidden?)
      .by_forum(Forum::UPDATES_FORUM)
      .limit(15)
      .as_views(true, true)
      .result
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

  def forums
    Forums::List.new.select { |forum| !forum.is_special }
  end

private

  def all_ongoings
    if new_ongoings.size < ONGOINGS_TAKE * 1.5
      new_ongoings + old_ongoings.take(ONGOINGS_TAKE * 1.5 - new_ongoings.size)
    else
      new_ongoings
    end
  end

  def new_ongoings
    OngoingsQuery.new(false)
      .fetch(ONGOINGS_FETCH)
      .where.not(id: IGNORE_ONGOINGS)
      .where("(#{THIS_SEASON_SQL}) OR (#{PRIOR_SEASON_SQL})")
      .where('score > 7.5')
      .decorate
  end

  def old_ongoings
    OngoingsQuery.new(false)
      .fetch(ONGOINGS_FETCH)
      .where.not(id: IGNORE_ONGOINGS)
      .where.not("(#{THIS_SEASON_SQL}) OR (#{PRIOR_SEASON_SQL})")
      .where('score > 7.5')
      .decorate
  end

  def all_reviews
    TopicsQuery.new(h.current_user, h.censored_forbidden?)
      .by_forum(reviews_forum)
      .limit(REVIEWS_FETCH)
      .as_views(true, true)
      .result
  end

  #def all_favourites
    #Anime
      #.where(id: FavouritesQuery.new.top_favourite_ids(Anime, FETCH_LIMIT))
      #.decorate
      #.shuffle
  #end

  def reviews_forum
    Forum.find_by_permalink('reviews')
  end

  def page
    (h.params[:page] || 1).to_i
  end
end
