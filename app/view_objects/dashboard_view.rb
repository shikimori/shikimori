class DashboardView < ViewObjectBase # rubocop:disable ClassLength
  CACHE_VERSION = :v8

  ONGOINGS_FETCH = 24
  ONGOINGS_TAKE = 8

  REVIEWS_FETCH = Rails.env.test? ? 1 : 3
  REVIEWS_TAKE = 1

  NEWS_LIMIT = 7

  DISPLAYED_HISTORY = 2

  SPECIAL_PAGES = 2

  CURRENT_SEASON_SQL = -> {
    Animes::Query.new(Anime.all)
      .by_season(Titles::SeasonTitle.new(Time.zone.now, :season_year, Anime).text)
      .to_where_sql
  }

  PRIOR_SEASON_SQL = -> {
    Animes::Query.new(Anime.all)
      .by_season(Titles::SeasonTitle.new(3.months.ago, :season_year, Anime).text)
      .to_where_sql
  }

  IGNORE_ONGOING_IDS = [
    31_592,
    32_585,
    35_517,
    32_977,
    8_687,
    36_231,
    38_008,
    38_427,
    39_003,
    40_368,
    48_753,
    49_520
  ]

  instance_cache :ongoings, :favourites, :critiques, :contests, :forums,
    :new_ongoings, :old_ongoings, :cache_keys

  def ongoings
    all_ongoings.shuffle.take(ONGOINGS_TAKE).sort_by(&:ranked)
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
    (Manga.kind.values - Ranobe::KINDS).map do |kind|
      Titles::KindTitle.new kind, Manga
    end
  end

  def db_others klass
    month = Time.zone.now.beginning_of_month
    # + 1.month since 12th month belongs to the next year in Titles::SeasonTitle
    is_still_this_year = (month + 2.months + 1.month).year == month.year

    [
      (Titles::StatusTitle.new(:anons, klass) unless klass.is_a?(Ranobe)),
      (Titles::StatusTitle.new(:ongoing, klass) if klass.is_a?(Ranobe)),
      Titles::SeasonTitle.new(month + 2.months, :year, klass),
      Titles::SeasonTitle.new(
        is_still_this_year ? 1.year.ago : 2.months.ago, :year, klass
      ),
      Titles::SeasonTitle.new(
        is_still_this_year ? 2.years.ago : 14.months.ago, :year, klass
      ),
      (
        if klass.is_a?(Ranobe)
          Titles::SeasonTitle.new(
            is_still_this_year ? 2.years.ago : 14.months.ago, :year, klass
          )
        end
      )
    ].compact
  end

  def critique_topic_views
    all_critique_topic_views
      .shuffle
      .reject { |view| view.topic.linked.target.censored? }
      .sort_by { |view| -view.topic.id }
      .select.with_index { |_critique, index| index == cache_keys[:critiques_index] }
  end

  def news_topic_views
    Topics::Query
      .fetch(h.current_user, h.censored_forbidden?)
      .by_forum(Forum.news, h.current_user, h.censored_forbidden?)
      .limit(NEWS_LIMIT)
      .paginate(page, NEWS_LIMIT)
      .as_views(true, true)
  end

  def generated_news_topic_views
    Topics::Query
      .fetch(h.current_user, true) # always hide hentai on the main page
      .by_forum(Forum::UPDATES_FORUM, h.current_user, true) # always hide hentai on the main page
      .limit(15)
      .as_views(true, true)

    # Topics::Query
    #   .fetch(h.censored_forbidden?)
    #   .by_forum(Forum::UPDATES_FORUM, h.current_user, h.censored_forbidden?)
    #   .limit(15)
    #   .as_views(true, true)
  end

  # def favourites
    # all_favourites.take(ONGOINGS_TAKE / 2).sort_by(&:ranked)
  # end

  def contests
    Contests::CurrentQuery.call
  end

  def list_counts kind
    h.current_user.list_stats.list_counts kind
  end

  def history
    Profiles::HistoryView.new(h.current_user).preview(DISPLAYED_HISTORY)
  end

  def forums
    Forums::List.new(with_forum_size: true).reject(&:is_special)
  end

  def cache_keys
    news_key = Topics::Query
      .new(Topic)
      .by_forum(Forum.news, h.current_user, h.censored_forbidden?)
      .first

    updates_key = Topics::Query
      .new(Topic)
      .by_forum(Forum::UPDATES_FORUM, h.current_user, h.censored_forbidden?)
      .first

    {
      ongoings: [:ongoings, rand(5), CACHE_VERSION],
      critiques: [Critique.order(id: :desc).first, CACHE_VERSION],
      critiques_index: rand(REVIEWS_FETCH), # to randomize critiques output
      news: [:news, news_key, CACHE_VERSION],
      updates: [:updates, updates_key, CACHE_VERSION],
      migration: h.domain_migration_note
    }
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

  def all_critique_topic_views
    Topics::Query
      .fetch(h.current_user, h.censored_forbidden?)
      .by_forum(critiques_forum, h.current_user, h.censored_forbidden?)
      .limit(REVIEWS_FETCH)
      .as_views(true, true)
  end

  # def all_favourites
    # Anime
      # .where(id: FavouritesQuery.new.top_favourite_ids(Anime, FETCH_LIMIT))
      # .decorate
      # .shuffle
  # end

  def critiques_forum
    Forum.find_by_permalink('critiques') # rubocop:disable DynamicFindBy
  end
end
