class DashboardViewV2 < ViewObjectBase # rubocop:disable ClassLength
  instance_cache :first_column_topic_views,
    :second_column_topic_views,
    :contest_topic_views,
    :hot_topic_views,
    :db_updates,
    :news_topic_views,
    :cache_variant,
    :cache_keys,
    :critiques_views,
    :articles_views,
    :collections_views,
    :history

  NEWS_FIRST_PAGE_LIMIT = 6
  NEWS_OTHER_PAGES_LIMIT = 15

  TOPICS_PER_COLUMN = 6

  DISPLAYED_HISTORY = 1

  ONGOINGS_FETCH = 24
  ONGOINGS_TAKE = 8
  IGNORE_ONGOING_IDS = DashboardView::IGNORE_ONGOING_IDS

  CURRENT_SEASON_SQL = DashboardView::CURRENT_SEASON_SQL
  PRIOR_SEASON_SQL = DashboardView::PRIOR_SEASON_SQL

  CACHE_VERSION = DashboardView::CACHE_VERSION

  TOPICS_EXCEPT_EXCLUDED_SQL = <<~SQL.squish
    not (
      topics.linked_type = 'Anime'
        and topics.linked_id in (#{IGNORE_ONGOING_IDS.join ','})
    )
  SQL

  def ongoings
    all_ongoings.shuffle.take(ONGOINGS_TAKE).sort_by(&:ranked)
  end

  def first_column_topic_views
    contest_topic_views +
      (critiques_views + articles_views + collections_views)
        .sort_by { |v| -v.created_at.to_i }
        .take(TOPICS_PER_COLUMN - contest_topic_views.size)
  end

  def second_column_topic_views
    displayed_ids = first_column_topic_views.map(&:id)

    critiques = critiques_views.reject { |v| displayed_ids.include? v.id }
    articles = articles_views.reject { |v| displayed_ids.include? v.id }
    collections = collections_views.reject { |v| displayed_ids.include? v.id }

    (
      take_n_plus_other(critiques, 1, 2) +
        take_n_plus_other(articles, 1, 2) +
        take_n_plus_other(collections, 1, 2)
    )
  end

  def contest_topic_views
    contests_scope
      .map do |contest|
        Topics::NewsLineView.new contest.maybe_topic(h.locale_from_host), true, true
      end
  end

  def hot_topic_views
    displayed_ids = (first_column_topic_views + second_column_topic_views)
      .map(&:id)

    Topics::HotTopicsQuery
      .call(limit: 12, locale: h.locale_from_host)
      .reject { |v| displayed_ids.include? v.id }
      .map { |topic| Topics::NewsLineView.new topic, true, true }
  end

  def news_topic_views
    news_scope
      .paginate(
        page,
        page == 1 ? NEWS_FIRST_PAGE_LIMIT : NEWS_OTHER_PAGES_LIMIT,
        page == 1 ? 0 : NEWS_FIRST_PAGE_LIMIT - NEWS_OTHER_PAGES_LIMIT
      )
      .lazy_map do |topic|
        Topics::NewsWallView.new topic, true, true
      end
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

  def manga_kinds
    (Manga.kind.values - Ranobe::KINDS).map do |kind|
      Titles::KindTitle.new kind, Manga
    end
  end

  def history
    entry = Profiles::HistoryView.new(h.current_user).preview(DISPLAYED_HISTORY).first

    Users::UserRateHistory.new entry.attributes if entry
  end

  def admin_area?
    h.params[:no_admin].blank? && h.current_user&.admin?
  end

  def cache_keys # rubocop:disable AbcSize
    {
      admin: [admin_area?, CACHE_VERSION],
      ongoings: [:ongoings, cache_variant, CACHE_VERSION],
      collections: [collections_scope.cache_key, CACHE_VERSION],
      articles: [articles_scope.cache_key, CACHE_VERSION],
      critiques: [critiques_scope.cache_key, CACHE_VERSION],
      contests: [contests_scope.cache_key, CACHE_VERSION],
      news: [news_scope.cache_key, page, CACHE_VERSION],
      db_updates: [db_updates_scope.cache_key, page, CACHE_VERSION],
      version: [Time.zone.today, cache_variant, CACHE_VERSION],
      migration: h.domain_migration_note
    }
  end

  def cache_variant
    :"variant-#{rand(5)}"
  end

  def new_news_url
    h.new_topic_url(
      'topic[user_id]' => 'USER_ID',
      'topic[type]' => Topics::NewsTopic.name,
      'topic[forum_id]' => Forum::NEWS_ID
    )
  end

private

  def all_ongoings
    if new_ongoings.size < ONGOINGS_TAKE * 1.5
      new_ongoings + old_ongoings.take((ONGOINGS_TAKE * 1.5) - new_ongoings.size)
    else
      new_ongoings
    end
  end

  def new_ongoings
    Animes::OngoingsQuery.new(false)
      .fetch(ONGOINGS_FETCH)
      .where.not(id: IGNORE_ONGOING_IDS)
      .where("(#{CURRENT_SEASON_SQL.call}) OR (#{PRIOR_SEASON_SQL.call})")
      .where('score > 7.3')
      .decorate
  end

  def old_ongoings
    Animes::OngoingsQuery.new(false)
      .fetch(ONGOINGS_FETCH)
      .where.not(id: IGNORE_ONGOING_IDS)
      .where.not("(#{CURRENT_SEASON_SQL.call}) OR (#{PRIOR_SEASON_SQL.call})")
      .where('score > 7.3')
      .decorate
  end

  def critiques_views
    critiques_scope.to_a
  end

  def articles_views
    articles_scope.to_a
  end

  def collections_views
    collections_scope.to_a
  end

  def take_n_plus_other scope, take_n, limit
    views = scope
      .sort_by { |view| -view.topic.id }

    n_views = views[0..(take_n - 1)]

    other_views = (views[take_n..] || []).shuffle
      .take(limit - take_n)
      .sort_by { |view| -view.topic.id }

    n_views + other_views
  end

  def build_view collection
  end

  def collections_scope
    Collections::Query
      .fetch(h.locale_from_host)
      .limit(16)
      .lazy_map do |collection|
        Topics::NewsLineView.new collection.maybe_topic(h.locale_from_host), true, true
      end
  end

  def articles_scope
    Articles::Query
      .fetch(h.locale_from_host)
      .limit(6)
      .lazy_map do |article|
        Topics::NewsLineView.new article.maybe_topic(h.locale_from_host), true, true
      end
  end

  def critiques_scope
    Topics::Query.fetch(h.locale_from_host, h.censored_forbidden?)
      .by_forum(critiques_forum, h.current_user, h.censored_forbidden?)
      .limit(6)
      .lazy_map do |topic|
        Topics::NewsLineView.new topic, true, true
      end
  end

  def contests_scope
    Contests::CurrentQuery.call
  end

  def news_scope
    Topics::Query.fetch(h.locale_from_host, h.censored_forbidden?)
      .by_forum(Forum.news, h.current_user, h.censored_forbidden?)
      .except(:order)
      .order(is_pinned: :desc, created_at: :desc)
  end

  def db_updates_scope
    Topics::Query.fetch(h.locale_from_host, true) # always hide hentai on the main page
      .by_forum(Forum::UPDATES_FORUM, h.current_user, true) # always hide hentai on the main page
      .where(TOPICS_EXCEPT_EXCLUDED_SQL)
  end

  def critiques_forum
    Forum.find_by_permalink('critiques') # rubocop:disable DynamicFindBy
  end

  def collections_forum
    Forum.find_by_permalink('collections') # rubocop:disable DynamicFindBy
  end
end
