class ProfileStatsQuery
  prepend ActiveCacher.instance

  vattr_initialize :user

  instance_cache :stats
  instance_cache :graph_statuses, :anime_spent_time, :manga_spent_time, :spent_time

  STAT_FIELDS = [
    :graph_statuses,
    :anime_spent_time,
    :manga_spent_time,
    :spent_time,
    :statuses,
    :full_statuses,
    :anime_ratings,
    :anime?,
    :manga?,
    :user,
  ]

  def to_hash
    stats_hash = STAT_FIELDS.each_with_object({}) do |method, memo|
      memo[method.to_s.sub(/\?/, '')] = public_send method
    end

    stats_hash.merge(
      activity: { 26 => activity(26), 34 => activity(34) },
      list_counts: { anime: list_counts(:anime), manga: list_counts(:manga) },
      scores: { anime: scores(:anime), manga: scores(:manga) },
      types: { anime: types(:anime), manga: types(:manga) },
    )
  end

  def graph_statuses
    stats.by_statuses
  end

  #def graph_time
    #GrapthTime.new spent_time
  #end

  def spent_time
    SpentTime.new anime_spent_time.days + manga_spent_time.days
  end

  def anime_spent_time
    time = stats.anime_rates.sum {|v| SpentTimeDuration.new(v).anime_hours v.entry_episodes, v.duration }
    SpentTime.new time / 60.0 / 24
  end

  def manga_spent_time
    time = stats.manga_rates.sum {|v| SpentTimeDuration.new(v).manga_hours v.entry_chapters, v.entry_volumes }
    SpentTime.new time / 60.0 / 24
  end

  #def genres
    #{
      #anime: stats.by_categories('genre', stats.genres, stats.anime_valuable_rates, [], 19),
      #manga: stats.by_categories('genre', stats.genres, [], stats.manga_valuable_rates, 19)
    #}
  #end

  #def studios
    #{ anime: stats.by_categories('studio', stats.studios.select {|v| v.real? }, stats.anime_valuable_rates, nil, 17) }
  #end

  #def publishers
    #{ manga: stats.by_categories('publisher', stats.publishers, nil, stats.manga_valuable_rates, 17) }
  #end

  def statuses
    { anime: stats.anime_statuses(false), manga: stats.manga_statuses(false) }
  end

  def full_statuses
    { anime: stats.anime_statuses(true), manga: stats.manga_statuses(true) }
  end

  def manga_statuses
  end

  def anime?
    stats.anime_rates.any?
  end

  def manga?
    stats.manga_rates.any?
  end

  def activity size
    stats.by_activity size
  end

  def list_counts list_type
    if list_type.to_sym == :anime
      stats.statuses stats.anime_rates, true
    else
      stats.statuses stats.manga_rates, true
    end
  end

  def scores list_type
    stats.by_criteria(:score, 1.upto(10).to_a.reverse)[list_type.to_sym]
  end

  def types list_type
    stats.by_criteria(
      :kind,
      list_type.to_s.capitalize.constantize.kind.values,
      "enumerize.#{list_type}.kind.short.%s"
    )[list_type.to_sym]
  end

  def anime_ratings
    stats.by_criteria(
      :rating,
      Anime.rating.values.select { |v| v != 'none' },
      'enumerize.anime.rating.%s'
    )[:anime]
  end

private

  # for rails_cache
  def cache_key_object
    @user
  end

  def stats
    Rails.cache.fetch [:user_statistics_query, user] do
      UserStatisticsQuery.new user
    end
  end
end
