class DashboardViewV2 < ViewObjectBase
  instance_cache :review_topic_views,
    :news,
    :db_updates,
    :cache_keys

  def contests
    Contests::CurrentQuery.call
  end

  def review_topic_views
    reviews_scope
      .as_views(true, true)
      .shuffle
      .reject { |view| view.topic.linked.target.censored? }
      .take(5 - contests.size)
      .sort_by { |view| -view.topic.id }
  end

  def news
    news_scope
      .paginate(page, page == 1 ? 8 : 15, page == 1 ? 0 : -7)
      .transform do |topic|
        Topics::NewsWallView.new topic, true, true
      end
  end

  def db_updates
    db_updates_scope
      .limit(15)
      .as_views(true, true)
  end

  def cache_keys
    {
      reviews: Review.order(id: :desc).first,
      news: [:news, news_scope.cache_key, page],
      db_updates: [:db_updates, db_updates_scope.cache_key, page]
    }
  end

  def anime_seasons
    [
      Titles::SeasonTitle.new(1.month.from_now, :season_year, Anime),
      Titles::SeasonTitle.new(Time.zone.now, :season_year, Anime),
      Titles::SeasonTitle.new(3.months.ago, :season_year, Anime)
    ]
      .uniq(&:short_title)
      .take(2)
  end

private

  def reviews_scope
    Topics::Query
      .fetch(h.locale_from_host)
      .by_forum(reviews_forum, h.current_user, h.censored_forbidden?)
      .limit(6)
  end

  def news_scope
    Topics::Query
      .fetch(h.locale_from_host)
      .by_forum(Forum.news, h.current_user, h.censored_forbidden?)
  end

  def db_updates_scope
    Topics::Query
      .fetch(h.locale_from_host)
      .by_forum(Forum::UPDATES_FORUM, h.current_user, h.censored_forbidden?)
  end

  def reviews_forum
    Forum.find_by_permalink('reviews')
  end
end
