$ ->
  $("#image_placeholder").hide()
  window.comments_notifier = new CommentsNotifier() if USER_SIGNED_IN

  colors = Highcharts.getOptions().colors
  _.extend total.series[0],
    dataLabels:
      formatter: ->
        (if @y > 5 then @point.name else null)

      color: "white"
      distance: -30
    size: "70%"

  _.extend total.series[1],
    dataLabels:
      formatter: ->
        (if @y > 20 then "<b>#{@point.name}</b>:<b>#{@y}</b>" else null)
    innerSize: "70%"

  _.each total.series[0].data, (v, k) ->
    v.color = colors[k]

  _.each total.series[1].data, (v, k) ->
    brightness = (k % 3) / 20
    index = parseInt(k / 3)
    v.color = Highcharts.Color(colors[index]).brighten(brightness).get()

  chart(
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

  # аниме по рейтингу
  $('.by_rating .control').first().trigger 'click'

  # аниме по жанрам
  $('.by_genre .control').first().trigger 'click'
  chart(
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

# переключение типа диаграммы рейтинга
$(document).on 'click', '.by_rating .control', ->
  $this = $(@).addClass 'selected'
  $this.siblings().removeClass 'selected'
  by_rating_chart.destroy() if 'by_rating_chart' of window
  chart(
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

# переключение типа диаграммы жанров
$(document).on "click", ".by_genre .control", ->
  $this = $(@).addClass "selected"
  $this.siblings().removeClass "selected"
  by_genre_chart.destroy() if "by_genre_chart" of window
  chart(
    'area',
    'by_genre',
    by_genre[$this.data('kind')],
    'percent',
    I18n.t('frontend.statistics.share'),
    (->
      I18n.t(
        'frontend.statistics.genres_share',
        percent: Highcharts.numberFormat(@percentage, 2, "."),
        rating: @series.name,
        year: @x
      )
    ),
    yAxis:
      max: 100
  )
