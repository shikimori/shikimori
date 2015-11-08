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

  # форматирует число дней в читабельную дату для графика онгоингов
  def date_title_for_ongoing days
    date = DateTime.now + days.days

    if days == 0
      today = t 'datetime.intervals.today'
      day_month_format = t 'date.formats.day_month_human'
      l date, format: "#{today}, #{day_month_format}"
    elsif date.year == DateTime.now.year
      l date, format: :ongoing_short
    else
      l date, format: :ongoing
    end
  end

  def color_by_num num
    @@colors[num]
  end

  def page_class page
    if page.kind_of? Array
      page[0].sub(/^edit$/, 'edit item-editor') + ' ' + page[1].map { |v| "#{page[0]}-#{v}" }.join(' ')
    else
      page
    end
  end
end
