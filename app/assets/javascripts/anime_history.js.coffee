#= require_tree ./social

$ ->
  $("#image_placeholder").hide()
  window.comments_notifier = new CommentsNotifier()  if IS_LOGGED_IN

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

  chart "pie", "total", total, "normal", "Количество", (->
    if @key.match(/^\d/)
      "<b>#{@y}</b> аниме с оценкой <b>#{@key}</b>"
    else
      "<b>#{@y}</b> аниме типа <b>#{@key}</b>"
  ),
    xAxis: null
    plotOptions:
      pie:
        shadow: false


  # аниме по типам
  chart "area", "by_kind", by_kind, "normal", "Количество", (->
    @y + " " + @series.name + " за " + @x + " год"
  ), {}

  # аниме по рейтингу
  $(".by_rating .control").first().trigger "click"

  # аниме по жанрам
  $(".by_genre .control").first().trigger "click"
  chart "area", "by_studio", by_studio, "normal", "Количество", (->
    @y + " аниме у " + @series.name + " за " + @x + " год"
  ),
    xAxis:
      categories: by_studio.categories
      labels:
        step: 1

      title:
        enabled: false

# переключение типа диаграммы рейтинга
$(document).on "click", ".by_rating .control", ->
  $this = $(@).addClass "selected"
  $this.siblings().removeClass "selected"
  by_rating_chart.destroy() if "by_rating_chart" of window
  chart "area", "by_rating", by_rating[$this.data("kind")], "percent", "Процент", (->
    Highcharts.numberFormat(@percentage, 2) + "% у " + @series.name + " за " + @x + " год"
  ),
    yAxis:
      max: 100

# переключение типа диаграммы жанров
$(document).on "click", ".by_genre .control", ->
  $this = $(@).addClass "selected"
  $this.siblings().removeClass "selected"
  by_genre_chart.destroy() if "by_genre_chart" of window
  chart "area", "by_genre", by_genre[$this.data("kind")], "percent", "Процент", (->
    Highcharts.numberFormat(@percentage, 2, ".") + "% у " + @series.name + " за " + @x + " год"
  ),
    yAxis:
      max: 100
