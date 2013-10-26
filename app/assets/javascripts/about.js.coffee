#= require pages/forum/appear
#= require pages/forum/faye

chart_options = (options) ->
  $.extend true,
    chart:
      zoomType: 'x'
      type: 'areaspline'
    title: null
    xAxis:
      type: "datetime"
      title: null
      maxZoom: 14 * 24 * 3600000
      dateTimeLabelFormats:
        millisecond: '%H:%M:%S.%L'
        second: '%H:%M:%S'
        minute: '%H:%M'
        hour: '%H:%M'
        day: '%e. %b'
        week: '%e. %b'
        month: '%b'
        year: '%Y'
    yAxis:
      title: null
      gridLineColor: "#eaeaea"
      min: 0
    tooltip:
      shared: true
    legend:
      borderRadius: 0
      borderWidth: 0
    plotOptions:
      areaspline:
        lineWidth: 1
        fillOpacity: 0.5
        marker:
          enabled: false
        shadow: false
        states:
          hover:
            lineWidth: 1
        threshold: null
    credits: false
  , options

$ =>
  traffic = $('.traffic-chart').data 'stats'
  $('.traffic-chart').highcharts chart_options
    series: [
      name: 'Просмотры'
      pointInterval: 24 * 3600 * 1000
      pointStart: Date.create(traffic.first().date).getTime()
      data: traffic.map (v) -> v.page_views
      visible: false
      color: Highcharts.getOptions().colors[3]
      fillColor:
        linearGradient:
          x1: 0
          y1: 0
          x2: 0
          y2: 1
        stops: [[0, Highcharts.getOptions().colors[3]], [1, Highcharts.Color(Highcharts.getOptions().colors[3]).setOpacity(0).get("rgba")]]
    ,
      name: 'Визиты'
      pointInterval: 24 * 3600 * 1000
      pointStart: Date.create(traffic.first().date).getTime()
      data: traffic.map (v) -> v.visits
      visible: false
      color: Highcharts.getOptions().colors[1]
      fillColor:
        linearGradient:
          x1: 0
          y1: 0
          x2: 0
          y2: 1
        stops: [[0, Highcharts.getOptions().colors[1]], [1, Highcharts.Color(Highcharts.getOptions().colors[1]).setOpacity(0).get("rgba")]]
    ,
      name: 'Уникальные посетители'
      pointInterval: 24 * 3600 * 1000
      pointStart: Date.create(traffic.first().date).getTime()
      data: traffic.map (v) -> v.visitors
      color: Highcharts.getOptions().colors[0]
      fillColor:
        linearGradient:
          x1: 0
          y1: 0
          x2: 0
          y2: 1
        stops: [[0, Highcharts.getOptions().colors[0]], [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get("rgba")]]
    ]

  comments = $('.comments-chart').data 'stats'
  comments_color = Highcharts.getOptions().colors[5]
  $('.comments-chart').highcharts chart_options
    series: [
      name: 'Комментариев за день'
      pointInterval: 24 * 3600 * 1000
      pointStart: Date.create(comments.first().date).getTime()
      data: comments.map (v) -> v.count
      color: comments_color
      fillColor:
        linearGradient:
          x1: 0
          y1: 0
          x2: 0
          y2: 1
        stops: [[0, comments_color], [1, Highcharts.Color(comments_color).setOpacity(0).get("rgba")]]
    ]
    legend:
      enabled: false

  @users = $('.users-chart').data 'stats'
  users_color = Highcharts.getOptions().colors[7]
  $('.users-chart').highcharts chart_options
    series: [
      name: 'Новых пользователей за день'
      pointInterval: 24 * 3600 * 1000
      pointStart: Date.create(users.first().date).getTime()
      #data: users.map (v) -> v.count
      data: users.map (v) -> [Date.create(v.date).getTime(), v.count]
      color: users_color
      fillColor:
        linearGradient:
          x1: 0
          y1: 0
          x2: 0
          y2: 1
        stops: [[0, users_color], [1, Highcharts.Color(users_color).setOpacity(0).get("rgba")]]
    ]
    legend:
      enabled: false
