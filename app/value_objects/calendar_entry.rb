class CalendarEntry < SimpleDelegator
  prepend ActiveCacher.instance

  attr_reader :anime, :locale
  instance_cache :last_news, :average_interval, :next_episode_start_at

  def initialize anime_with_data, locale
    super anime_with_data

    @anime = anime_with_data
    @locale = locale
  end

  def average_interval
    if anime.episodes_aired.zero?
      0
    else
      episode_news_topics.size < 2 ? 7.days : episode_average_interval
    end
  end

  def last_news
    episode_news_topics.sort_by { |entry| entry.value.to_i }.last
  end

  def next_episode
    if ongoing? && last_news
      last_news.value.to_i+1
    else
      1
    end
  end

  def last_episode_date
    last_news.created_at if ongoing? && last_news
  end

  def next_episode_start_at
    anime.next_episode_at ||
      aired_at ||
      broadcast_at ||
      anime_calendars.first&.start_at
  end

  def next_episode_end_at
    next_episode_start_at + ((duration.zero? ? 26 : duration) + 5).minutes
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
    prior_time = episode_news_topics.first.created_at
    # учитываем только последние восемь записей
    episode_news_topics.reverse.take(8).reverse.each do |news|
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

  def aired_at
    if anime.aired_on && anime.aired_on.to_datetime >= 1.day.ago
      anime.aired_on.to_datetime
    end
  end

  def broadcast_at
    return unless anime.broadcast_at

    if anime.broadcast_at > 1.hour.ago
      anime.broadcast_at
     elsif last_news && anime.broadcast_at - last_news.created_at < 14.days
      anime.broadcast_at + 1.week
    end
  end

  def episode_news_topics
    anime.episode_news_topics.select { |v| v.locale == locale }
  end
end
