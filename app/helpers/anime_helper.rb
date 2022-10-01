# TODO: remove this helper
module AnimeHelper
  # время выхода следующей серии
  def time_of_next_episode anime
    episode_start = anime.next_episode_start_at# || (last_news&.created_at || anime.aired_on.date) + anime.average_interval
    episode_end = anime.next_episode_end_at# || (last_news&.created_at || anime.aired_on.date) + anime.average_interval

    # идёт ли показ прямо сейчас?
    if episode_start <= Time.zone.now && episode_end >= Time.zone.now
      'сейчас на ТВ'
    # пока завершён?
    elsif episode_end < Time.zone.now
      str = "%s" % time_ago_in_words(episode_end, "%s назад").sub(" #{Time.zone.now.year}", '').sub('около ', '')
      if str =~ /час/
        hours = str.match(/\d+/)[0].to_i
        Russian.p(hours, "#{hours} час назад", "#{hours} часа назад", "#{hours} часов назад")
      else
        str
      end
    # показ ещё не стартовал
    else
      "с #{anime.next_episode_start_at.strftime('%H:%M')} по #{anime.next_episode_end_at.strftime('%H:%M')}"
    end
  end

  def humanize_minutes(minutes)
    return "0 #{t 'anime_helper.minute'}" if minutes.zero?

    hours = (minutes/60).floor.to_i

    if hours > 0
      text = "#{hours} #{t 'anime_helper.hour', count: hours}" 
    else
      text = ''
    end

    raw_minutes = minutes % 60
    text += ' ' if hours > 0 && raw_minutes > 0

    if raw_minutes > 0
      if raw_minutes % 10 == 1
        text += "#{raw_minutes} #{t 'anime_helper.minute'}"

      elsif raw_minutes % 10 > 1 && raw_minutes % 10 < 5
        text += "#{raw_minutes} #{t 'anime_helper.minute'}"

      else
        text += "#{raw_minutes} #{t 'anime_helper.minute'}"
      end
    end

    text
  end

  def truncate_html(text, options)
    super(text.gsub('№', 'CODE_N').gsub('°', 'CODE_PER'), options).gsub('CODE_N', '№').gsub('CODE_PER', '°')
  end

  def average_score(scores)
    return '' unless scores
    return '' if scores.respond_to?(:[]) && !scores.is_a?(Integer) && (scores.empty? || scores.sum == 0)
    return scores unless scores.respond_to?(:[]) && !scores.is_a?(Integer)
    total = 0
    scores.each_with_index do |v,k|
      total += (k+1)*v
    end
    "%.2f" % [total*1.0 / scores.sum]
  end
end
