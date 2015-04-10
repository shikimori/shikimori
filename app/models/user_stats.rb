class UserStats
  prepend ActiveCacher.instance

  instance_cache :graph_statuses, :spent_time
  instance_cache :comments_count, :comments_reviews_count, :reviews_count, :user_changes_count, :uploaded_videos_count

  def initialize user, current_user
    @user = user
    @current_user = current_user

    @stats = Rails.cache.fetch [:stats, :v7, @user] do
      UserStatisticsQuery.new @user
    end
  end

  def graph_statuses
    @stats.by_statuses
  end

  #def graph_time
    #GrapthTime.new spent_time
  #end

  def spent_time
    anime_time = @stats.anime_rates.sum {|v| SpentTimeDuration.new(v).anime_hours v.entry_episodes, v.duration }
    manga_time = @stats.manga_rates.sum {|v| SpentTimeDuration.new(v).anime_hours v.entry_chapters, v.entry_volumes }

    SpentTime.new((anime_time + manga_time) / 60.0 / 24)
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
    localize_spent_time spent_time, true
  end

  def spent_time_label
    gender_label = 'Время'#@user.male? ? 'Провёл' : 'Провела'
    kind_label = if anime? && manga?
      'аниме и мангой'
    elsif manga?
      'мангой'
    else
      'аниме'
    end

    "#{gender_label} за #{kind_label}"
  end

  def time_since_signup
    time = SpentTime.new((Time.zone.now - User.first.created_at) / 1.day)
    localize_spent_time time, false
  end

  def activity
    @stats.by_activity 26
  end

  def list_counts list_type
    if list_type.to_sym == :anime
      @stats.statuses @stats.anime_rates, true
    else
      @stats.statuses @stats.manga_rates, true
    end
  end

  def scores list_type
    @stats.by_criteria(:score, 1.upto(10).to_a.reverse)[list_type.to_sym]
  end

  def types list_type
    i18n = !@current_user || (@current_user && @current_user.preferences.russian_genres?) ?
      ':klass.Short.%s' : nil

    all_types = ['TV', 'Movie', 'OVA', 'ONA', 'Music', 'Special'] + ["Manga", "One Shot", "Manhwa", "Manhua", "Novel", "Doujin"]
    @stats.by_criteria(:kind, all_types, i18n)[list_type.to_sym]
  end

  def ratings list_type
    @stats.by_criteria(:rating, ['G', 'PG', 'PG-13', 'R+', 'NC-17', 'Rx'].reverse)[list_type.to_sym]#, -> v { v[:rating] != 'None' }
  end

  def genres
    {
      anime: @stats.by_categories('genre', @stats.genres, @stats.anime_valuable_rates, [], 19),
      manga: @stats.by_categories('genre', @stats.genres, [], @stats.manga_valuable_rates, 19)
    }
  end

  def studios
    { anime: @stats.by_categories('studio', @stats.studios.select {|v| v.real? }, @stats.anime_valuable_rates, nil, 17) }
  end

  def publishers
    { manga: @stats.by_categories('publisher', @stats.publishers, nil, @stats.manga_valuable_rates, 17) }
  end

  def statuses
    { anime: @stats.anime_statuses(false), manga: @stats.manga_statuses(false) }
  end

  def full_statuses
    { anime: @stats.anime_statuses(true), manga: @stats.manga_statuses(true) }
  end

  def manga_statuses
  end

  def social_activity?
    comments_count > 0 || comments_reviews_count > 0 || reviews_count > 0 ||
      content_changes_count > 0 || videos_changes_count > 0
  end

  def comments_count
    Comment.where(user_id: @user.id).count
  end

  def comments_reviews_count
    Comment.where(user_id: @user.id, review: true).count
  end

  def reviews_count
    @user.reviews.count
  end

  def content_changes_count
    @user.user_changes.where(status: [UserChangeStatus::Taken, UserChangeStatus::Accepted]).count
  end

  def videos_changes_count
    AnimeVideoReport.where(user: @user).where.not(state: 'rejected').count
  end

  def anime?
    @stats.anime_rates.any?
  end

  def manga?
    @stats.manga_rates.any?
  end

private
  def localize_spent_time time, is_genitive
    if time.days.zero?
      '0 часов'

    elsif time.years >= 1
      months = time.months_part > 0 ? " и #{I18n.time_part(time.months_part.to_i, :month)}" : ''
      I18n.time_part(time.years.to_i, :year) + months

    elsif time.months >= 1
      weeks = time.weeks_part > 0 ?
        " и #{I18n.time_part(time.weeks_part.to_i, :week)}" : ''
      weeks.sub! '1 неделя', '1 неделю' if is_genitive
      I18n.time_part(time.months.to_i, :month) + weeks

    elsif time.weeks >= 1
      days = time.days_part > 0 ? " и #{I18n.time_part(time.days_part.to_i, :day)}" : ''
      I18n.time_part(time.weeks.to_i, :week) + days

    elsif time.days >= 1
      hours = time.hours_part > 0 ? " и #{I18n.time_part(time.hours_part.to_i, :hour)}" : ''
      I18n.time_part(time.days.to_i, :day) + hours

    elsif time.hours >= 1
      minutes = time.minutes_part > 0 ?
        " и #{I18n.time_part(time.minutes_part.to_i, :minute)}" : ''
      minutes.sub! '1 неделя', '1 неделю' if is_genitive

      I18n.time_part(time.hours.to_i, :hour) + minutes

    elsif time.minutes >= 1
      I18n.time_part(time.minutes.to_i, :minute)
    end
  end
end
