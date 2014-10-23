class UserStatsDecorator
  prepend ActiveCacher.instance

  instance_cache :graph_statuses, :spent_time

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
    anime_time = @stats.anime_rates.sum {|v| (v.episodes + v.rewatches * v.episodes) * v.duration }
    manga_time = @stats.manga_rates.sum {|v| (v.chapters + v.rewatches * v.chapters) * v.duration }

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
    if spent_time.days.zero?
      '0 часов'

    elsif spent_time.years >= 1
      months = spent_time.months_part > 0 ? " и #{I18n.time_part(spent_time.months_part.to_i, :month)}" : ''
      I18n.time_part(spent_time.years.to_i, :year) + months

    elsif spent_time.months >= 1
      weeks = spent_time.weeks_part > 0 ?
        " и #{I18n.time_part(spent_time.weeks_part.to_i, :week)}".sub('1 неделя', '1 неделю') : ''
      I18n.time_part(spent_time.months.to_i, :month) + weeks

    elsif spent_time.weeks >= 1
      days = spent_time.days_part > 0 ? " и #{I18n.time_part(spent_time.days_part.to_i, :day)}" : ''
      I18n.time_part(spent_time.weeks.to_i, :week) + days

    elsif spent_time.days >= 1
      hours = spent_time.hours_part > 0 ? " и #{I18n.time_part(spent_time.hours_part.to_i, :hour)}" : ''
      I18n.time_part(spent_time.days.to_i, :day) + hours

    elsif spent_time.hours >= 1
      minutes = spent_time.minutes_part > 0 ?
        " и #{I18n.time_part(spent_time.minutes_part.to_i, :minute)}".sub('1 минута', '1 минуту') : ''
      I18n.time_part(spent_time.hours.to_i, :hour) + minutes

    elsif spent_time.minutes >= 1
      I18n.time_part(spent_time.minutes.to_i, :minute)
    end
  end

  def activity
    @stats.by_activity 26
  end

  #def statuses
    #{ anime: @stats.anime_statuses, manga: @stats.manga_statuses }
  #end

  #def full_statuses
    #{
      #anime: @stats.statuses(@stats.anime_rates, true),
      #manga: @stats.statuses(@stats.manga_rates, true)
    #}
  #end

  #def scores
    #@stats.by_criteria :score, 1.upto(10).to_a.reverse
  #end

  #def types
    #i18n = !@current_user || (@current_user && @current_user.preferences.russian_genres?) ?
      #':klass.Short.%s' : nil

    #@stats.by_criteria :kind, ['TV', 'Movie', 'OVA', 'ONA', 'Music', 'Special'] + ["Manga", "One Shot", "Manhwa", "Manhua", "Novel", "Doujin"], i18n
  #end

  #def ratings
    #@stats.by_criteria :rating, ['G', 'PG', 'PG-13', 'R+', 'NC-17', 'Rx'].reverse#, -> v { v[:rating] != 'None' }
  #end

  #def anime?
    #@stats.anime_rates.any?
  #end

  #def manga?
    #@stats.manga_rates.any?
  #end

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
end
