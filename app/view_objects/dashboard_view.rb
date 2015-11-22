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

  def anime_seasons
    [
      SeasonTitle.new(3.months.from_now, :season_year),
      SeasonTitle.new(Time.zone.now, :season_year),
      SeasonTitle.new(3.months.ago, :season_year),
      SeasonTitle.new(6.months.ago, :season_year)
    ]
  end

  def anime_others
    month = Time.zone.now.beginning_of_month
    # + 1.month since 12th month belongs to the next year in SeasonTitle
    is_still_this_year = (month + 2.months + 1.month).year == month.year

    [
      StatusTitle.new(:anons, Anime),
      SeasonTitle.new(month + 2.months, :year),
      SeasonTitle.new(is_still_this_year ? 1.year.ago : month, :year),
      SeasonTitle.new(is_still_this_year ? 2.years.ago : 1.year.ago, :year),
    ]
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

  def forums
    Section.visible.map do |section|
      OpenStruct.new(
        name: section.name,
        url: h.section_url(section),
        size: TopicsQuery.new(h.current_user).by_section(section).size
      )
    end
    # [
      # 'Аниме',
      # 'Манга',
      # 'Визуальные новеллы',
      # 'Игры',
      # 'Новости',
      # 'Рецензии',
      # 'Опросы',
      # 'Сайт',
      # 'Оффтопик'
    # ]
  end

private

  def all_ongoings
    this_season = AnimeSeasonQuery.new(
      SeasonTitle.new(Time.zone.now, :season_year).text,
      Anime
    ).to_sql

    prior_season = AnimeSeasonQuery.new(
      SeasonTitle.new(3.month.ago, :season_year).text,
      Anime
    ).to_sql

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
