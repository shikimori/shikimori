class DashboardViewV2 < ViewObjectBase
  instance_cache :news, :db_updates, :cache_keys

  def news
    news_scope
      .limit(15)
      .paginate(page, 15)
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
      news: [:news, news_scope.cache_key],
      db_updates: [:db_updates, db_updates_scope.cache_key]
    }
  end

private

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
end
