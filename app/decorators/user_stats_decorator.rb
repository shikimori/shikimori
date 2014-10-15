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
    if @user.preferences.manga_first?
      @stats.by_statuses.reverse
    else
      @stats.by_statuses
    end
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
      "%g #{Russian.p spent_time.years.round(1).to_i, 'год', 'года', 'лет'}" % spent_time.years.round(1)

    elsif spent_time.months >= 1
      "%g #{Russian.p spent_time.months.round(1).to_i, 'месяц', 'месяца', 'месяцев'}" % spent_time.months.round(1)

    elsif spent_time.weeks >= 1
      "%g #{Russian.p spent_time.weeks.round(1).to_i, 'неделя', 'недели', 'недель'}" % spent_time.weeks.round(1)

    elsif spent_time.days >= 1
      "%g #{Russian.p spent_time.days.round(1).to_i, 'день', 'дня', 'дней'}" % spent_time.days.round(1)

    elsif spent_time.hours >= 1
      "%g #{Russian.p spent_time.hours.round(1).to_i, 'час', 'часа', 'часов'}" % spent_time.hours.round(1)

    elsif spent_time.minutes >= 1
      "%g #{Russian.p spent_time.minutes.round(1).to_i, 'минута', 'минуты', 'минут'}" % spent_time.minutes.round(1)
    end
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

  #def genres
    #{
      #anime: @stats.by_categories('genre', @stats.genres, @stats.anime_valuable_rates, [], 19),
      #manga: @stats.by_categories('genre', @stats.genres, [], @stats.manga_valuable_rates, 19)
    #}
  #end

  #def studios
    #{ anime: by_categories('studio', @stats.studios.select {|v| v.real? }, @stats.anime_valuable_rates, nil, 17) }
  #end

  #def publishers
    #{ manga: by_categories('publisher', @stats.publishers, nil, @stats.manga_valuable_rates, 17) }
  #end

  #def activity
    #by_activity 42 #41
  #end
end
