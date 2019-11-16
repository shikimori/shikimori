class DashboardViewV2 < ViewObjectBase
  instance_cache :collection_topic_views,
    :review_topic_views,
    :news_topic_views,
    :contest_topic_views,
    :hot_topic_views,
    :db_updates,
    :cache_keys

  CACHE_VERSION = :v8
  NEWS_FIRST_PAGE_LIMIT = 6
  NEWS_OTHER_PAGES_LIMIT = 15

  def collection_topic_views
    take_2_plus_other(
      collections_scope,
      contest_topic_views.size.zero? ? 6 : 6 - contest_topic_views.size
    )
  end

  def review_topic_views
    take_2_plus_other(
      reviews_scope,
      6
    )
  end

  def contests
    contests_scope
  end

  def news_topic_views
    news_scope
      .paginate(
        page,
        page == 1 ? NEWS_FIRST_PAGE_LIMIT : NEWS_OTHER_PAGES_LIMIT,
        page == 1 ? 0 : NEWS_FIRST_PAGE_LIMIT - NEWS_OTHER_PAGES_LIMIT
      )
      .transform do |topic|
        Topics::NewsWallView.new topic, true, true
      end
  end

  def contest_topic_views
    contests_scope
      .map do |contest|
        Topics::NewsLineView.new contest.maybe_topic(h.locale_from_host), true, true
      end
  end

  def hot_topic_views
    Topics::HotTopicsQuery
      .call(h.locale_from_host)
      .map { |topic| Topics::NewsLineView.new topic, true, true }
  end

  def db_updates
    db_updates_scope
      .limit(8)
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

  def admin_area?
    h.params[:no_admin].blank? && h.current_user&.admin?
  end

  def cache_keys
    {
      admin: admin_area?,
      versions: [Date.today, :"variant-#{rand(5)}", CACHE_VERSION],
      collections: collections_scope.cache_key,
      reviews: reviews_scope.cache_key,
      contests: contests_scope.cache_key,
      news: [news_scope.cache_key, page],
      db_updates: [db_updates_scope.cache_key, page]
    }
  end

private

  def take_2_plus_other scope, limit
    views = scope
      .sort_by { |view| -view.topic.id }

    two_views = views[0..1]

    other_views = (views[2..-1] || []).shuffle
      .take(limit - 2)
      .sort_by { |view| -view.topic.id }

    two_views + other_views
  end

  def build_view collection
  end

  def collections_scope
    Collections::Query
      .fetch(h.locale_from_host)
      .limit(16)
      .transform do |collection|
        Topics::NewsLineView.new collection.maybe_topic(h.locale_from_host), true, true
      end
  end

  def reviews_scope
    Topics::Query
      .fetch(h.locale_from_host)
      .by_forum(reviews_forum, h.current_user, h.censored_forbidden?)
      .limit(10)
      .transform { |topic| Topics::NewsLineView.new topic, true, true }
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
