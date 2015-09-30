class ProfileStatsView
  include Translation
  include Virtus.model
  prepend ActiveCacher.instance

  ProfileStatsQuery::STAT_FIELDS.each do |field|
    attribute field.to_s.sub(/\?/, '')
  end

  attribute :activity
  attribute :list_counts
  attribute :scores
  attribute :types

  instance_cache :comments_count, :comments_reviews_count, :reviews_count,
    :versions_count, :videos_changes_count

  def anime?
    anime
  end

  def manga?
    manga
  end

  def activity size
    @activity[size]
  end

  def list_counts list_type
    @list_counts[list_type.to_sym]
  end

  def scores list_type
    @scores[list_type.to_sym]
  end

  def types list_type
    @types[list_type.to_sym]
  end

  def spent_time_percent
    part = 20

    #if spent_time.hours > 0 && spent_time.hours <= 1
      #spent_time.hours * part / 2

    if spent_time.weeks > 0 && spent_time.weeks <= 1
      spent_time.weeks * part / 2

    elsif spent_time.months > 0 && spent_time.months <= 1
      10 + (spent_time.days - 7) / 23 * part

    elsif spent_time.months_3 > 0 && spent_time.months_3 <= 1
      30 + (spent_time.days - 30) / 60 * part

    elsif spent_time.months_6 > 0 && spent_time.months_6 <= 1
      50 + (spent_time.days - 90) / 90 * part

    elsif spent_time.years > 0 && spent_time.years <= 1
      70 + (spent_time.days - 180) / 185 * part

    elsif spent_time.years > 1 && spent_time.years <= 1.5
      90 + (spent_time.days - 365) / 182.5 * (part / 2)

    elsif spent_time.years > 1.5
      100

    else
      0
    end.round
  end

  def spent_time_in_words
    I18n.spent_time spent_time, false
  end

  def spent_time_in_days
    anime_days = anime_spent_time.days > 10 ? anime_spent_time.days.to_i : anime_spent_time.days.round(1)
    manga_days = manga_spent_time.days > 10 ? manga_spent_time.days.to_i : manga_spent_time.days.round(1)
    total_days = spent_time.days > 10 ? spent_time.days.to_i : spent_time.days.round(1)

    days_text = "Всего #{total_days.zero? ? 0 : total_days} " +
      Russian.p(total_days, 'день', 'дня', 'дней', 'дней')

    if anime_spent_time.days >= 0.5 && manga_spent_time.days >= 0.5
      "#{days_text}: " +
        "#{anime_days} #{Russian.p(anime_days, 'день', 'дня', 'дней', 'дней')} аниме" +
        " и #{manga_days} #{Russian.p(manga_days, 'день', 'дня', 'дней', 'дней')} манга"

    elsif anime_spent_time.days >= 1
      "#{days_text} аниме"

    elsif manga_spent_time.days >= 1
      "#{days_text} манга"

    else
      days_text
    end
  end

  def spent_time_label
    i18n_key = if anime? && manga?
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

  def social_activity?
    comments_count > 0 || comments_reviews_count > 0 || reviews_count > 0 ||
      versions_count > 0 || videos_changes_count > 0
  end

  def comments_count
    Comment.where(user_id: user.id).count
  end

  def comments_reviews_count
    Comment.where(user_id: user.id, review: true).count
  end

  def reviews_count
    user.reviews.count
  end

  def versions_count
    user.versions.where(state: [:taken, :accepted]).count
  end

  def videos_changes_count
    AnimeVideoReport.where(user: user).where.not(state: 'rejected').count
  end
end
