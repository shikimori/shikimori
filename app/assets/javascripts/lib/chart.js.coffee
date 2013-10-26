# получение данных для графика
@chart = (type, id, data, stacking, y_title, tooltip_formatter, options) ->
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
