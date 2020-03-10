# TODO: refactor
class Users::ProfileStatsQuery
  prepend ActiveCacher.instance

  vattr_initialize :user

  instance_cache :stats, :anime_spent_time, :manga_spent_time, :spent_time

  CACHE_VERSION = :v5

  def to_profile_stats
    stats_hash = Profiles::Stats.attributes.each_with_object({}) do |k, memo|
      memo[k] = public_send(k)
    end

    Profiles::Stats.new stats_hash
  end

  def activity
    {
      26 => activity_by_size(26),
      34 => activity_by_size(34)
    }
  end

  def anime_ratings
    stats.by_criteria(
      :rating,
      Anime.rating.values.reject { |v| v == 'none' },
      'enumerize.anime.rating.%s'
    )[:anime]
  end

  def anime_spent_time
    time = stats.anime_rates
      .select(&:duration)
      .sum do |extended_user_rate|
        SpentTimeDuration
          .new(extended_user_rate)
          .anime_hours(extended_user_rate.entry_episodes, extended_user_rate.duration)
      end

    SpentTime.new(time / 60.0 / 24)
  end

  def full_statuses
    {
      anime: stats.anime_statuses(true),
      manga: stats.manga_statuses(true)
    }
  end

  def is_anime
    stats.anime_rates.any?
  end

  def is_manga
    stats.manga_rates.any?
  end

  def list_counts
    {
      anime: list_counts_by_type(:anime),
      manga: list_counts_by_type(:manga)
    }
  end

  def manga_spent_time
    time = stats.manga_rates.sum do |extended_user_rate|
      SpentTimeDuration
        .new(extended_user_rate)
        .manga_hours(extended_user_rate.entry_chapters, extended_user_rate.entry_volumes)
    end
    SpentTime.new(time / 60.0 / 24)
  end

  def scores
    {
      anime: scores_by_type(:anime),
      manga: scores_by_type(:manga)
    }
  end

  def spent_time
    SpentTime.new(anime_spent_time.days + manga_spent_time.days)
  end

  def stats_bars
    stats.stats_bars
  end

  def statuses
    {
      anime: stats.anime_statuses(false),
      manga: stats.manga_statuses(false)
    }
  end

  def kinds
    {
      anime: kinds_by_type(:anime),
      manga: kinds_by_type(:manga)
    }
  end

  # def graph_time
    # GrapthTime.new spent_time
  # end

  def genres
    {
      anime: stats.by_categories(
        'genre',
        AnimeGenresRepository.instance.to_a,
        stats.anime_valuable_rates,
        [],
        19
      ),
      manga: stats.by_categories(
        'genre',
        MangaGenresRepository.instance.to_a,
        [],
        stats.manga_valuable_rates,
        19
      )
    }
  end

  def studios
    {
      anime: stats.by_categories(
        'studio',
        StudiosRepository.instance.select(&:is_visible),
        stats.anime_valuable_rates,
        nil,
        17
      )
    }
  end

  def publishers
    {
      manga: stats.by_categories(
        'publisher',
        PublishersRepository.instance.to_a,
        nil,
        stats.manga_valuable_rates,
        17
      )
    }
  end

  private

  def activity_by_size size
    stats.by_activity size
  end

  def list_counts_by_type type
    if type.to_sym == :anime
      stats.anime_statuses true
    else
      stats.manga_statuses true
    end
  end

  def scores_by_type type
    stats.by_criteria(
      :score,
      1.upto(10).to_a.reverse
    )[type.to_sym]
  end

  def kinds_by_type type
    stats.by_criteria(
      :kind,
      type.to_s.capitalize.constantize.kind.values,
      "enumerize.#{type}.kind.short.%s"
    )[type.to_sym]
  end

  # for ActiveCacher
  def cache_key_object
    @user
  end

  def stats
    Rails.cache.fetch [:user_statistics_query, user, CACHE_VERSION] do
      Users::StatisticsQuery.new user
    end
  end
end
