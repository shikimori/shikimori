class CalendarEntry < SimpleDelegator
  attr_accessor :anime

  def initialize anime_with_data
    super
    @anime = anime_with_data
  end

  def average_interval
    @average_interval ||= if anime.episodes_aired.zero?
      0
    else
      anime.episodes_news.size < 2 ? 7.days : episode_average_interval
    end
  end

  def last_news
    @last_news ||= episodes_news.sort_by {|n| n.value.to_i }.last
  end

  def next_episode
    @next_episode ||= if status == AniMangaStatus::Ongoing && last_news
      last_news.value.to_i+1
    else
      1
    end
  end

  def last_episode_date
    @last_episode_date ||= last_news.created_at if status == AniMangaStatus::Ongoing && last_news
  end

  def next_episode_at
    if anime.next_episode_at.blank? && episode_start_at.present?
      episode_start_at
    else
      anime.aired_on.to_datetime
    end
  end

  def episode_start_at
    @episode_start_at ||= anime_calendars.first.start_at if anime_calendars.any?
  end

  def episode_end_at
    @episode_end_at ||= episode_start_at + ((duration.zero? ? 26 : duration) + 5).minutes if anime_calendars.any?
  end

  # для совместимости с декорированными объектами
  def decorated?
    true
  end
  def object
    anime
  end

private
  # вычисление среднего интервала между выходами серий
  def episode_average_interval
    times = []
    prior_time = episodes_news.first.created_at
    # учитываем только последние восемь записей
    episodes_news.reverse.take(8).reverse.each do |news|
      next if prior_time == news.created_at
      times << (news.created_at - prior_time).abs#/60/60/24
      prior_time = news.created_at
    end
    # считаем только по половине интервалов, отсекаем четверть самых коротких и четверть самых длинных
    # и берём срок не менее недели
    interval = if times.size >= 4
      times.sort.slice(times.size/4, times.size).take(times.size/2).sum/(times.size/2)
    else
      times.sum/times.size
    end

    [7.days, interval].max
  end
end
