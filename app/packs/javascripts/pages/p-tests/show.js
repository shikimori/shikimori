// import Wall from '@/views/wall/view';

pageLoad('tests_show', async () => {
  // new Wall($('.images-test .shiki-wall'));

  // const Highcharts = await import(/* webpackChunkName: "highcharts" */ 'highcharts');
  // initPage(Highcharts);
});

// function initPage(Highcharts) {
//   const traffic = $('.traffic-test').data('stats');
// 
//   $('.traffic-test').highcharts(
//     chartOptions({
//       series: [{
//         name: 'Просмотры',
//         pointInterval: 24 * 3600 * 1000,
//         pointStart: new Date(traffic.first().date).getTime(),
//         data: traffic.map(v => v.page_views),
//         visible: false,
//         color: Highcharts.getOptions().colors[3],
//         fillColor: {
//           linearGradient: {
//             x1: 0,
//             y1: 0,
//             x2: 0,
//             y2: 1
//           },
//           stops: [
//             [0, Highcharts.getOptions().colors[3]],
//             [1, Highcharts.Color(Highcharts.getOptions().colors[3]).setOpacity(0).get('rgba')]
//           ]
//         }
//       }, {
//         name: 'Визиты',
//         pointInterval: 24 * 3600 * 1000,
//         pointStart: new Date(traffic.first().date).getTime(),
//         data: traffic.map(v => v.visits),
//         visible: false,
//         color: Highcharts.getOptions().colors[1],
//         fillColor: {
//           linearGradient: {
//             x1: 0,
//             y1: 0,
//             x2: 0,
//             y2: 1
//           },
//           stops: [
//             [0, Highcharts.getOptions().colors[1]],
//             [1, Highcharts.Color(Highcharts.getOptions().colors[1]).setOpacity(0).get('rgba')]
//           ]
//         }
//       }, {
//         name: 'Уникальные посетители',
//         pointInterval: 24 * 3600 * 1000,
//         pointStart: new Date(traffic.first().date).getTime(),
//         data: traffic.map(v => v.visitors),
//         color: Highcharts.getOptions().colors[0],
//         fillColor: {
//           linearGradient: {
//             x1: 0,
//             y1: 0,
//             x2: 0,
//             y2: 1
//           },
//           stops: [
//             [0, Highcharts.getOptions().colors[0]],
//             [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
//           ]
//         }
//       }]
//     })
//   );
// }
// 
// const chartOptions = options =>
//   Object.merge({
//     chart: {
//       zoomType: 'x',
//       type: 'areaspline'
//     },
//     title: null,
//     xAxis: {
//       type: 'datetime',
//       title: null,
//       maxZoom: 14 * 24 * 3600000,
//       dateTimeLabelFormats: {
//         millisecond: '%H:%M:%S.%L',
//         second: '%H:%M:%S',
//         minute: '%H:%M',
//         hour: '%H:%M',
//         day: '%e. %b',
//         week: '%e. %b',
//         month: '%b',
//         year: '%Y'
//       }
//     },
//     yAxis: {
//       title: null,
//       gridLineColor: '#eaeaea',
//       min: 0
//     },
//     tooltip: {
//       shared: true
//     },
//     legend: {
//       borderRadius: 0,
//       borderWidth: 0
//     },
//     plotOptions: {
//       areaspline: {
//         lineWidth: 1,
//         fillOpacity: 0.5,
//         marker: {
//           enabled: false
//         },
//         shadow: false,
//         states: {
//           hover: {
//             lineWidth: 1
//           }
//         },
//         threshold: null
//       }
//     },
//     credits: false
//   }, options, { deep: true });
