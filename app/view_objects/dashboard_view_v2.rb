class DashboardViewV2 < ViewObjectBase
  instance_cache :collection_topic_views,
    :review_topic_views,
    :news_topic_views,
    :db_updates,
    :cache_keys

  def collection_topic_views
    collections_scope
      .as_views(true, true)
      .shuffle
      .take(6)
      .sort_by { |view| -view.topic.id }
  end

  def review_topic_views # rubocop:disable AbcSize
    reviews_scope
      .as_views(true, true)
      .shuffle
      .reject { |view| view.topic.linked.target.censored? }
      .take(6 - (contests.size.zero? ? 0 : contests.size + 1))
      .sort_by { |view| -view.topic.id }
  end

  def contests
    contests_scope
  end

  def news_topic_views
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

  def anime_seasons
    [
      Titles::SeasonTitle.new(1.month.from_now, :season_year, Anime),
      Titles::SeasonTitle.new(Time.zone.now, :season_year, Anime),
      Titles::SeasonTitle.new(3.months.ago, :season_year, Anime)
    ]
      .uniq(&:short_title)
      .take(2)
  end

  def cache_keys
    {
      versions: [Date.today, :"variant-#{rand(5)}", :v2],
      collections: collections_scope.cache_key,
      reviews: reviews_scope.cache_key,
      contests: contests_scope.cache_key,
      news: [:news, news_scope.cache_key, page],
      db_updates: [:db_updates, db_updates_scope.cache_key, page]
    }
  end

private

  def collections_scope
    Topics::Query
      .fetch(h.locale_from_host)
      .by_forum(collections_forum, h.current_user, h.censored_forbidden?)
      .limit(12)
  end

  def reviews_scope
    Topics::Query
      .fetch(h.locale_from_host)
      .by_forum(reviews_forum, h.current_user, h.censored_forbidden?)
      .limit(8)
  end

  def contests_scope
    Contests::CurrentQuery.call
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

  def collections_forum
    Forum.find_by_permalink('collections')
  end
end
