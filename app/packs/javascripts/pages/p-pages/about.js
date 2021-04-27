pageLoad('pages_about', async () => {
  const Highcharts = await import(/* webpackChunkName: "highcharts" */ 'highcharts');
  const { colors } = await import(/* webpackChunkName: "highcharts" */ 'vendor/highcharts_colors');

  Highcharts.getOptions().colors.length = 0;
  colors.forEach(color => Highcharts.getOptions().colors.push(color));

  trafficChart(Highcharts);
  commentsChart(Highcharts);
  usersChart(Highcharts);
});

function commentsChart(Highcharts) {
  const data = $('.comments-chart').data('stats');
  const color = Highcharts.getOptions().colors[3];

  $('.comments-chart').highcharts(
    chartOptions({
      series: [{
        name: I18n.t('frontend.about.comments_per_day'),
        pointInterval: 24 * 3600 * 1000,
        pointStart: new Date(data.first().date).getTime(),
        data: data.map(v => v.count),
        color,
        fillColor: {
          linearGradient: {
            x1: 0,
            y1: 0,
            x2: 0,
            y2: 1
          },
          stops: [
            [0, color],
            [1, Highcharts.Color(color).setOpacity(0).get('rgba')]
          ]
        }
      }
      ],
      legend: {
        enabled: false
      }
    })
  );
}

function usersChart(Highcharts) {
  const data = $('.users-chart').data('stats');
  const color = Highcharts.getOptions().colors[4];

  $('.users-chart').highcharts(
    chartOptions({
      series: [{
        name: I18n.t('frontend.about.new_users_per_day'),
        pointInterval: 24 * 3600 * 1000,
        pointStart: new Date(data.first().date).getTime(),
        data: data.map(v => [new Date(v.date).getTime(), v.count]),
        color,
        fillColor: {
          linearGradient: {
            x1: 0,
            y1: 0,
            x2: 0,
            y2: 1
          },
          stops: [
            [0, color],
            [1, Highcharts.Color(color).setOpacity(0).get('rgba')]
          ]
        }
      }
      ],
      legend: {
        enabled: false
      }
    })
  );
}

function trafficChart(Highcharts) {
  const data = $('.traffic-chart').data('stats');
  const colors = [
    Highcharts.getOptions().colors[2],
    Highcharts.getOptions().colors[1],
    Highcharts.getOptions().colors[0]
  ];

  return $('.traffic-chart').highcharts(chartOptions({
    series: [{
      name: I18n.t('frontend.about.views'),
      pointInterval: 24 * 3600 * 1000,
      pointStart: new Date(data.first().date).getTime(),
      data: data.map(v => v.page_views),
      visible: false,
      color: colors[0],
      fillColor: {
        linearGradient: {
          x1: 0,
          y1: 0,
          x2: 0,
          y2: 1
        },
        stops: [
          [0, colors[0]],
          [1, Highcharts.Color(colors[0]).setOpacity(0).get('rgba')]
        ]
      }
    }, {
      name: I18n.t('frontend.about.visits'),
      pointInterval: 24 * 3600 * 1000,
      pointStart: new Date(data.first().date).getTime(),
      data: data.map(v => v.visits),
      visible: false,
      color: colors[1],
      fillColor: {
        linearGradient: {
          x1: 0,
          y1: 0,
          x2: 0,
          y2: 1
        },
        stops: [
          [0, colors[1]],
          [1, Highcharts.Color(colors[1]).setOpacity(0).get('rgba')]
        ]
      }
    }, {
      name: I18n.t('frontend.about.unique_visitors'),
      pointInterval: 24 * 3600 * 1000,
      pointStart: new Date(data.first().date).getTime(),
      data: data.map(v => v.visitors),
      color: colors[2],
      fillColor: {
        linearGradient: {
          x1: 0,
          y1: 0,
          x2: 0,
          y2: 1
        },
        stops: [
          [0, colors[2]],
          [1, Highcharts.Color(colors[2]).setOpacity(0).get('rgba')]
        ]
      }
    }]
  }));
}

const chartOptions = options =>
  Object.merge({
    chart: {
      zoomType: 'x',
      type: 'areaspline'
    },
    title: null,
    xAxis: {
      type: 'datetime',
      title: null,
      maxZoom: 14 * 24 * 3600000,
      dateTimeLabelFormats: {
        millisecond: '%H:%M:%S.%L',
        second: '%H:%M:%S',
        minute: '%H:%M',
        hour: '%H:%M',
        day: '%e. %b',
        week: '%e. %b',
        month: '%b',
        year: '%Y'
      }
    },
    yAxis: {
      title: null,
      gridLineColor: '#eaeaea',
      min: 0
    },
    tooltip: {
      shared: true
    },
    legend: {
      borderRadius: 0,
      borderWidth: 0
    },
    plotOptions: {
      areaspline: {
        lineWidth: 1,
        fillOpacity: 0.5,
        marker: {
          enabled: false
        },
        shadow: false,
        states: {
          hover: {
            lineWidth: 1
          }
        },
        threshold: null
      }
    },
    credits: false
  }, options, { deep: true });
