module PagesHelper
  @@colors = {
    -1 => 'gray',
    0 => 'blue',
    1 => 'powderblue',
    2 => 'skyblue',
    3 => 'purple',
    4 => 'green',
    5 => 'yellow',
    6 => 'orange',
    7 => 'red',
    8 => 'pink',
    9 => 'magenta',
    10 => 'brown'
  }

  def format_news_body(entry)
    text = cut(entry.text)
    text.sub!(/(\[poster\][\s\S]*?\[\/poster\])([\s\S]*)/, '\1')
    format_comment(text, entry.user).gsub(/<a href=/, '<a rel="nofollow" href=')
  end

  # форматирует число дней в читабельную дату для графика онгоингов
  def date_title_for_ongoing(days)
    date = DateTime.now + days.days
    if days == 0
      Russian::strftime(date, 'Сегодня, %e %B')
    elsif date.year == DateTime.now.year
      Russian::strftime(date, '%A, %e %B')
    else
      Russian::strftime(date, '%A, %e %B %Y')
    end
  end

  def color_by_num(num)
    @@colors[num]
  end

  def page_class(page)
    if page.kind_of? Array
      page[0].sub(/^edit$/, 'edit item-editor') + ' ' + page[1].map { |v| "#{page[0]}-#{v}" }.join(' ')
    else
      page
    end
  end
end
