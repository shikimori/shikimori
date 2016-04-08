# TODO: remove this helper
module AnimeHelper
  # время выхода следующей серии
  def time_of_next_episode anime
    episode_start = anime.next_episode_start_at# || (last_news&.created_at || anime.aired_on) + anime.average_interval
    episode_end = anime.next_episode_end_at# || (last_news&.created_at || anime.aired_on) + anime.average_interval

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
    return '0 мин.' if minutes == 0
    text = ''

    hours = (minutes/60).floor.to_i
    text += '%i час' % hours if hours == 1
    text += '%i часа' % hours if hours > 1 && hours < 5
    text += '%i часов' % hours if hours > 4

    raw_minutes = minutes % 60
    text += ' ' if hours > 0 && raw_minutes > 0

    if raw_minutes > 0
      if raw_minutes % 10 == 1
        text += '%i мин.' % raw_minutes
      elsif raw_minutes % 10 > 1 && raw_minutes % 10 < 5
        text += '%i мин.' % raw_minutes
      else
        text += '%i мин.' % raw_minutes
      end
    end

    text
  end

  def truncate_html(text, options)
    super(text.gsub('№', 'CODE_N').gsub('°', 'CODE_PER'), options).gsub('CODE_N', '№').gsub('CODE_PER', '°')
  end

  def average_score(scores)
    return '' unless scores
    return '' if scores.respond_to?(:[]) && !scores.kind_of?(Fixnum) && (scores.empty? || scores.sum == 0)
    return scores unless scores.respond_to?(:[]) && !scores.kind_of?(Fixnum)
    total = 0
    scores.each_with_index do |v,k|
      total += (k+1)*v
    end
    "%.2f" % [total*1.0 / scores.sum]
  end
end
