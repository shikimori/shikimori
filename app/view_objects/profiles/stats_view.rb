class Users::ListStatsView # rubocop:disable ClassLength
  pattr_initialize :profile_stats

  include Translation
  prepend ActiveCacher.instance

  instance_cache :comments_count, :topics_count, :summaries_count,
    :reviews_count, :collections_count,
    :versions_count, :video_uploads_count, :video_reports_count, :video_versions_count

  delegate :anime_ratings, :anime_spent_time, :full_statuses, :manga,
    :list_counts, :manga_spent_time, :spent_time, :stats_bars, :statuses,
    :user, :genres, :studios, :publishers,
    to: :profile_stats

  def anime?
    profile_stats.is_anime
  end

  def manga?
    profile_stats.is_manga
  end

  def activity size
    profile_stats.activity[size]
  end

  def list_counts list_type
    profile_stats.list_counts[list_type.to_sym]
  end

  def scores list_type
    profile_stats.scores[list_type.to_sym]
  end

  def kinds list_type
    profile_stats.kinds[list_type.to_sym]
  end

  def spent_time_percent # rubocop:disable all
    part = 20

    # if spent_time.hours > 0 && spent_time.hours <= 1
      # spent_time.hours * part / 2

    if spent_time.weeks.positive? && spent_time.weeks <= 1
      spent_time.weeks * part / 2.0

    elsif spent_time.months.positive? && spent_time.months <= 1
      10 + (spent_time.days - 7) / 23.0 * part

    elsif spent_time.months_3.positive? && spent_time.months_3 <= 1
      30 + (spent_time.days - 30) / 60.0 * part

    elsif spent_time.months_6.positive? && spent_time.months_6 <= 1
      50 + (spent_time.days - 90) / 90.0 * part

    elsif spent_time.years.positive? && spent_time.years <= 1
      70 + (spent_time.days - 180) / 185.0 * part

    elsif spent_time.years > 1 && spent_time.years <= 1.5
      90 + (spent_time.days - 365) / 182.5 * (part / 2)

    elsif spent_time.years > 1.5
      100

    else
      0
    end.round
  end

  def spent_time_in_words
    SpentTimeView.new(spent_time).text
  end

  def spent_time_in_days # rubocop:disable all
    anime_days =
      if anime_spent_time.days > 10
        anime_spent_time.days.to_i
      else
        anime_spent_time.days.round(1)
      end
    manga_days =
      if manga_spent_time.days > 10
        manga_spent_time.days.to_i
      else
        manga_spent_time.days.round(1)
      end
    total_days =
      if spent_time.days > 10
        spent_time.days.to_i
      else
        spent_time.days.round(1)
      end

    if anime_spent_time.days >= 0.5 && manga_spent_time.days >= 0.5
      i18n_t(
        'spent_time_in_days.anime_manga',
        total_days_count: (total_days.zero? ? 0 : total_days),
        total_days: i18n_t('day', count: total_days),
        anime_days_count: anime_days,
        anime_days: i18n_t('day', count: anime_days),
        manga_days_count: manga_days,
        manga_days: i18n_t('day', count: manga_days)
      )

    elsif anime_spent_time.days >= 1
      i18n_t(
        'spent_time_in_days.anime',
        anime_days_count: anime_days,
        anime_days: i18n_t('day', count: anime_days)
      )

    elsif manga_spent_time.days >= 1
      i18n_t(
        'spent_time_in_days.manga',
        manga_days_count: manga_days,
        manga_days: i18n_t('day', count: manga_days)
      )

    else
      i18n_t(
        'spent_time_in_days.default',
        total_days_count: (total_days.zero? ? 0 : total_days),
        total_days: i18n_t('day', count: total_days)
      )
    end
  end

  def spent_time_label
    i18n_key =
      if anime? && manga?
        'anime_manga'
      elsif manga?
        'manga'
      else
        'anime'
      end

    i18n_t "time_spent.#{i18n_key}"
  end

  def time_since_signup
    time = SpentTime.new((Time.zone.now - User.first.created_at) / 1.day)
    localize_spent_time time, false
  end
end
