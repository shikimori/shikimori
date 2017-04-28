page_load 'pages_about', ->
  require.ensure [], (require) =>
    init_charts require('highcharts')

init_charts = (Highcharts) ->
  Highcharts.setOptions
    global:
      useUTC: false

  colors_old = Object.clone Highcharts.getOptions().colors
  colors_d3 = ['#1f77b4', '#aec7e8', '#ff7f0e', '#ffbb78', '#2ca02c', '#98df8a', '#d62728', '#ff9896', '#9467bd', '#c5b0d5', '#8c564b', '#c49c94', '#e377c2', '#f7b6d2', '#7f7f7f', '#c7c7c7', '#bcbd22', '#dbdb8d', '#17becf', '#9edae5']
  colors_hz = ['#44bbff', '#c09eda', '#9bd51f', '#f7b42c', '#f27490', '#fc575e', '#f27624', '#90d5ec', '#f49ac1', '#ca5', '#b5e4f2', '#9ab']

  Highcharts.getOptions().colors.length = 0
  # colors = ['#4682b4', '#2ca02c', '#d65757', '#db843d', '#a47d7c', '#bcbd22', '#ff9896', '#f7b42c', '#80699b', '#c5b0d5'].concat(colors_hz)
  # colors = [].concat(colors_d3)
  colors = [].concat(colors_hz)

  colors.forEach (color) -> Highcharts.getOptions().colors.push(color)

  traffic_chart Highcharts
  comments_chart Highcharts
  users_chart Highcharts

traffic_chart = (Highcharts, data) ->
  data = $('.traffic-chart').data('stats')
  colors = [
    Highcharts.getOptions().colors[2],
    Highcharts.getOptions().colors[1],
    Highcharts.getOptions().colors[0]
  ]

  $('.traffic-chart').highcharts chart_options
    series: [
      name: I18n.t('frontend.about.views')
      pointInterval: 24 * 3600 * 1000
      pointStart: new Date(data.first().date).getTime()
      data: data.map (v) -> v.page_views
      visible: false
      color: colors[0]
      fillColor:
        linearGradient:
          x1: 0
          y1: 0
          x2: 0
          y2: 1
        stops: [
          [0, colors[0]],
          [1, Highcharts.Color(colors[0]).setOpacity(0).get("rgba")]
        ]
    ,
      name: I18n.t('frontend.about.visits')
      pointInterval: 24 * 3600 * 1000
      pointStart: new Date(data.first().date).getTime()
      data: data.map (v) -> v.visits
      visible: false
      color: colors[1]
      fillColor:
        linearGradient:
          x1: 0
          y1: 0
          x2: 0
          y2: 1
        stops: [
          [0, colors[1]],
          [1, Highcharts.Color(colors[1]).setOpacity(0).get("rgba")]
        ]
    ,
      name: I18n.t('frontend.about.unique_visitors')
      pointInterval: 24 * 3600 * 1000
      pointStart: new Date(data.first().date).getTime()
      data: data.map (v) -> v.visitors
      color: colors[2]
      fillColor:
        linearGradient:
          x1: 0
          y1: 0
          x2: 0
          y2: 1
        stops: [
          [0, colors[2]],
          [1, Highcharts.Color(colors[2]).setOpacity(0).get("rgba")]
        ]
    ]

comments_chart = (Highcharts, data)->
  data = $('.comments-chart').data('stats')
  color = Highcharts.getOptions().colors[3]

  $('.comments-chart').highcharts chart_options
    series: [
      name: I18n.t('frontend.about.comments_per_day')
      pointInterval: 24 * 3600 * 1000
      pointStart: new Date(data.first().date).getTime()
      data: data.map (v) -> v.count
      color: color
      fillColor:
        linearGradient:
          x1: 0
          y1: 0
          x2: 0
          y2: 1
        stops: [
          [0, color],
          [1, Highcharts.Color(color).setOpacity(0).get("rgba")]
        ]
    ]
    legend:
      enabled: false

users_chart = (Highcharts, data) ->
  data = $('.users-chart').data('stats')
  color = Highcharts.getOptions().colors[4]

  $('.users-chart').highcharts chart_options
    series: [
      name: I18n.t('frontend.about.new_users_per_day')
      pointInterval: 24 * 3600 * 1000
      pointStart: new Date(data.first().date).getTime()
      data: data.map (v) -> [new Date(v.date).getTime(), v.count]
      color: color
      fillColor:
        linearGradient:
          x1: 0
          y1: 0
          x2: 0
          y2: 1
        stops: [
          [0, color],
          [1, Highcharts.Color(color).setOpacity(0).get("rgba")]
        ]
    ]
    legend:
      enabled: false

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
