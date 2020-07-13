pageLoad('statistics_lists', async () => {
  const Highcharts = await import(/* webpackChunkName: "highcharts" */ 'highcharts');
  const { colors } = await import(/* webpackChunkName: "highcharts" */ 'vendor/highcharts_colors');

  Highcharts.getOptions().colors.length = 0;
  colors.forEach(color => Highcharts.getOptions().colors.push(color));

  $('.chart').toArray().forEach(node => {
    const stats = $(node).data('stats');
    const type = node.getAttribute('data-type');
    if (!stats) { return; }

    renderCharts(Highcharts, node, stats, type);
  });
});

function renderCharts(Highcharts, node, stats, type) {
  Highcharts.chart(node, {
    chart: {
      type: 'area'
    },
    title: {
      text: `Size distribution of ${type} lists`
    },
    xAxis: {
      categories: Object.keys(stats)
    },
    yAxis: {
      title: {
        text: 'Users'
      }
    },
    credits: {
      enabled: false
    },
    series: [{
      name: type,
      data: Object.values(stats)
    }]
  });
}
