pageLoad 'statistics_index', ->
  $('#image_placeholder').hide()

  require.ensure [], (require) =>
    Highcharts = require('highcharts')

    Highcharts.getOptions().colors.length = 0
    require('vendor/highcharts_colors').forEach (color) ->
      Highcharts.getOptions().colors.push(color)

    render_charts Highcharts
    handle_events Highcharts

    # аниме по рейтингу
    $('.by_rating .control').first().trigger 'click'

    # аниме по жанрам
    $('.by_genre .control').first().trigger 'click'


render_charts = (Highcharts) ->
  colors = Highcharts.getOptions().colors
  Object.merge total.series[0],
    dataLabels:
      formatter: ->
        (if @y > 5 then @point.name else null)

      color: 'white'
      distance: -30
    size: '70%'

  Object.merge total.series[1],
    dataLabels:
      formatter: ->
        (if @y > 20 then "<b>#{@point.name}</b>:<b>#{@y}</b>" else null)
    innerSize: '70%'

  total.series[0].data.forEach (v, k) ->
    v.color = colors[k]

  total.series[1].data.forEach (v, k) ->
    brightness = (k % 3) / 20
    index = parseInt(k / 3)
    v.color = Highcharts.Color(colors[index]).brighten(brightness).get()

  chart(
    Highcharts,
    'pie',
    'total',
    total,
    'normal',
    I18n.t('frontend.statistics.number'),
    (->
      if @key.match(/^\d/)
        I18n.t('frontend.statistics.anime_with_score', count: @y, score: @key)
      else
        I18n.t('frontend.statistics.anime_of_type', count: @y, type: @key)
    ),
    xAxis: null
    plotOptions:
      pie:
        shadow: false
  )

  # аниме по типам
  chart(
    Highcharts,
    'area',
    'by_kind',
    by_kind,
    'normal',
    I18n.t('frontend.statistics.number'),
    (->
      I18n.t(
        'frontend.statistics.anime_in_year',
        count: @y,
        type: @series.name,
        year: @x
      )
    ),
    {}
  )

  chart(
    Highcharts,
    'area',
    'by_studio',
    by_studio,
    'normal',
    I18n.t('frontend.statistics.number'),
    (->
      I18n.t(
        'frontend.statistics.anime_with_rating_in_year',
        count: @y,
        rating: @series.name,
        year: @x
      )
    ),
    xAxis:
      categories: by_studio.categories
      labels:
        step: 1
      title:
        enabled: false
  )

handle_events = (Highcharts) ->
  # переключение типа диаграммы жанров
  $('.l-page').on 'click', '.by_genre .control', ->
    $this = $(@).addClass "selected"
    $this.siblings().removeClass "selected"
    by_genre_chart.destroy() if "by_genre_chart" of window
    chart(
      Highcharts,
      'area',
      'by_genre',
      by_genre[$this.data('kind')],
      'percent',
      I18n.t('frontend.statistics.share'),
      (->
        I18n.t(
          'frontend.statistics.genres_share',
          percent: Highcharts.numberFormat(@percentage, 2, "."),
          genre: @series.name,
          year: @x
        )
      ),
      yAxis:
        max: 100
    )

  # переключение типа диаграммы рейтинга
  $('.l-page').on 'click', '.by_rating .control', ->
    $this = $(@).addClass 'selected'
    $this.siblings().removeClass 'selected'
    by_rating_chart.destroy() if 'by_rating_chart' of window
    chart(
      Highcharts,
      'area',
      'by_rating',
      by_rating[$this.data('kind')],
      'percent',
      I18n.t('frontend.statistics.share'),
      (->
        I18n.t(
          'frontend.statistics.ratings_share',
          percent: Highcharts.numberFormat(@percentage, 2),
          rating: @series.name,
          year: @x
        )
      ),
      yAxis:
        max: 100
    )

# получение данных для графика
chart = (Highcharts, type, id, data, stacking, y_title, tooltip_formatter, options) ->
  defaults =
    chart:
      renderTo: id
      type: type

    title:
      text: ""

    subtitle:
      text: ""

    xAxis:
      categories: data.categories
      labels:
        step: 2

      title:
        enabled: false

    yAxis:
      title:
        text: y_title

      labels:
        formatter: ->
          @value

    tooltip:
      formatter: tooltip_formatter
      borderRadius: 0
      borderWidth: 1
      shadow: false

    plotOptions:
      area:
        stacking: stacking
        lineColor: "#666666"
        lineWidth: 1
        shadow: false
        marker:
          enabled: false
          lineWidth: 1
          lineColor: "#666666"

    credits:
      enabled: false

    legend:
      borderRadius: 0
      borderWidth: 0

    #floating: true,
    #align: 'left',
    #verticalAlign: 'top',
    #x: 20,
    #y: 0
    series: data.series

  window["#{id}_chart"] = new Highcharts.Chart $.extend(true, defaults, options or {})
