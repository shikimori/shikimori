@on 'page:load', 'profiles_show', ->
  # добавление/удаление из друзей
  $('.friend-action').on 'ajax:success', ->
    $('.friend-action').toggle()

  # добавление/удаление в игнор
  $('.ignore-action').on 'ajax:success', ->
    $('.ignore-action').toggle()

  # тултип на никнейм
  $('h1.aliases').tipsy
    gravity: 'w'
    html: true
    prependTo: document.body

  $('.activity .graph').bar
    before: (stats, options, $chart) ->
      # конвертируем даты
      stats.each (stat, index) ->
        stat.dates =
          from: new Date(stat.name[0] * 1000)
          to: new Date(stat.name[1] * 1000)

      # всякое для тайтлов осей
      options.interval = Math.round date_diff(stats[0].dates.from, stats[0].dates.to)
      options.range = Math.round date_diff(stats[0].dates.from, stats[stats.length - 1].dates.to)
      options.index_label = 0

      if options.y_axis
        $chart.addClass "y-axis"
        # прозрачные полоски
        html = []
        i = 1

        while i <= 10
          html.push "<div class=\"ruler\" style=\"top: " + i * 10 + "%;\"></div>"
          i++
        $chart.html html.join("")

    title: (entry) ->
      days = date_diff entry.dates.from, entry.dates.to

      "#{entry.value} #{p entry.value, 'час', 'часа', 'часов'} с " +
        "#{moment(entry.dates.from).format('DD MMMM')} по #{moment(entry.dates.to).format('DD MMMM')} " +
        if days == Math.round(days) then "(#{days} #{p days, 'день', 'дня', 'дней'})" else "(#{days} дня)"

    x_axis: (entry, index, stats, options) ->
      # пропуск, пока индекс меньше следующего_допустимого
      return "" if index < options.index_label
      from = entry.dates.from
      to = entry.dates.to
      if index == 0
        options.index_label = 3
        label = from.getFullYear()

      else if options.prior
        if options.prior.dates.from.getFullYear() != from.getFullYear()
          label = from.getFullYear()
          options.index_label = index + 3

        else if options.prior.dates.from.getMonth() != from.getMonth()
          label = moment(from).format('MMM')
          options.index_label = index + 3

        else if options.range <= 120 and entry.value > 0
          label = from.getDate()
          options.index_label = index + 2

      options.prior = entry
      label || ""

    no_data: ($chart) ->
      $chart.html("<p class=\"stat-sorry\">#{$chart.data 'no_stat_text'}</p>").removeClass("bar").attr "id", false

date_diff = (date_earlier, date_later) ->
  one_day = 1000 * 60 * 60 * 24
  Math.round((date_later.getTime() - date_earlier.getTime()) / one_day * 10) / 10
