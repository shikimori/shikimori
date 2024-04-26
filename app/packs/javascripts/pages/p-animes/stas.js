import { dailyChartOptions } from '@/pages/p-pages/about';
import keys from 'lodash/keys';

pageLoad('animes_stats', async () => {
  const Highcharts = await import(/* webpackChunkName: "hs" */ 'highcharts');
  const { colors } = await import(/* webpackChunkName: "hs" */ '@/vendor/highcharts_colors');

  Highcharts.getOptions().colors.length = 0;
  colors.forEach(color => Highcharts.getOptions().colors.push(color));

  chart($('.list_stats-chart'), Highcharts);
  chart($('.scores_stats-chart'), Highcharts);
});

function chart($node, Highcharts) {
  const data = $node.data('stats');
  const colors = Highcharts.getOptions().colors;

  const statFields = keys(data[0]).filter(field => field !== 'date');

  return $node.highcharts(dailyChartOptions({
    series: statFields.map((field, index) => ({
      name: field,
      pointInterval: 24 * 3600 * 1000,
      pointStart: new Date(data[0].date).getTime(),
      data: data.map(v => v[field]),
      visible: true
    }))
  }, { isStacking: true }));
}
