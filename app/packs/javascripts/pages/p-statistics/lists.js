pageLoad('statistics_lists', async () => {
  const Highcharts = await import(/* webpackChunkName: "highcharts" */ 'highcharts');
  const { colors } = await import(/* webpackChunkName: "highcharts" */ '@/vendor/highcharts_colors');

  Highcharts.getOptions().colors.length = 0;
  colors.forEach(color => Highcharts.getOptions().colors.push(color));

  $('.chart').toArray().forEach(node => {
    const stats = $(node).data('stats');
    const label = node.getAttribute('data-label');
    if (!stats) { return; }

    renderCharts(Highcharts, { node, stats, label });
  });
});

function renderCharts(Highcharts, { node, stats, label }) {
  const keys = Object.keys(stats);

  Highcharts.chart(node, {
    chart: { type: 'area' },
    title: { text: label },
    xAxis: {
      categories: Object.keys(stats[keys[0]]).sortBy(v => parseInt(v.replace(/[^\d].*/, '')))
    },
    yAxis: {
      title: { text: 'Users' }
    },
    credits: { enabled: false },
    // plotOptions: {
    //   area: {
    //     stacking: 'normal'
    //   }
    // },
    tooltip: {
      split: true
    },
    series: Object
      .keys(stats)
      .map(key => ({ name: key, data: Object.values(stats[key]) }))
      .sortBy(({ data }) => -data[0])
  });
}
