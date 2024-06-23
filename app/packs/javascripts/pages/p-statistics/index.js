import merge from 'lodash/merge';
import I18n from '@/utils/i18n';

pageLoad('statistics_index', async () => {
  $('#image_placeholder').hide();

  const Highcharts = await import(/* webpackChunkName: "hs" */ 'highcharts');
  const { colors } = await import(/* webpackChunkName: "hs" */ '@/vendor/highcharts_colors');

  Highcharts.getOptions().colors.length = 0;
  colors.forEach(color => Highcharts.getOptions().colors.push(color));

  const stats = $('header.head').data('statistics');

  renderCharts(stats, Highcharts);
  handleEvents(stats, Highcharts);

  $('.by_rating .control').first().trigger('click');
  $('.by_genre .control').first().trigger('click');
});

function renderCharts({ total, byKind, byStudio }, Highcharts) {
  const { colors } = Highcharts.getOptions();
  merge(total.series[0], {
    dataLabels: {
      formatter() {
        if (this.y > 5) { return this.point.name; } else { return null; }
      },

      color: 'white',
      distance: -30
    },
    size: '70%'
  });

  merge(total.series[1], {
    dataLabels: {
      formatter() {
        if (this.y > 20) {
          return `<b>${this.point.name}</b>:<b>${this.y}</b>`;
        } else {
          return null;
        }
      }
    },
    innerSize: '70%'
  });

  total.series[0].data.forEach((v, k) => v.color = colors[k]);

  total.series[1].data.forEach(function(v, k) {
    const brightness = (k % 3) / 20;
    const index = parseInt(k / 3);
    return v.color = new Highcharts.Color(colors[index]).brighten(brightness).get();
  });

  chart(
    Highcharts,
    'pie',
    'total',
    total,
    'normal',
    I18n.t('frontend.statistics.number'),
    function() {
      if (this.key.match(/^\d/)) {
        return I18n.t('frontend.statistics.anime_with_score', { count: this.y, score: this.key });
      } else {
        return I18n.t('frontend.statistics.anime_of_type', { count: this.y, type: this.key });
      }
    }, {
      xAxis: null,
      plotOptions: {
        pie: {
          shadow: false
        }
      }
    }
  );

  // аниме по типам
  chart(
    Highcharts,
    'area',
    'by_kind',
    byKind,
    'normal',
    I18n.t('frontend.statistics.number'),
    function() {
      return I18n.t(
        'frontend.statistics.anime_in_year', {
          count: this.y,
          type: this.series.name,
          year: this.x
        }
      );
    },
    {}
  );

  chart(
    Highcharts,
    'area',
    'by_studio',
    byStudio,
    'normal',
    I18n.t('frontend.statistics.number'),
    function() {
      return I18n.t(
        'frontend.statistics.anime_with_rating_in_year', {
          count: this.y,
          rating: this.series.name,
          year: this.x
        }
      );
    },
    {
      xAxis: {
        categories: byStudio.categories,
        labels: {
          step: 1
        },
        title: {
          enabled: false
        }
      }
    }
  );
}

function handleEvents({ byGenre, byRating }, Highcharts) {
  // переключение типа диаграммы жанров
  $('.l-page').on('click', '.by_genre .control', function() {
    const $this = $(this).addClass('selected');
    $this.siblings().removeClass('selected');

    if ('by_genre_chart' in window) {
      window.by_genre_chart.destroy();
    }

    chart(
      Highcharts,
      'area',
      'by_genre',
      byGenre[$this.data('kind')],
      'percent',
      I18n.t('frontend.statistics.share'),
      function() {
        return I18n.t(
          'frontend.statistics.genres_share', {
            percent: Highcharts.numberFormat(this.percentage, 2, '.'),
            genre: this.series.name,
            year: this.x
          }
        );
      }, {
        yAxis: {
          max: 100
        }
      }
    );
  });

  // переключение типа диаграммы рейтинга
  $('.l-page').on('click', '.by_rating .control', function() {
    const $this = $(this).addClass('selected');
    $this.siblings().removeClass('selected');
    if ('by_rating_chart' in window) {
      window.by_rating_chart.destroy();
    }

    chart(
      Highcharts,
      'area',
      'by_rating',
      byRating[$this.data('kind')],
      'percent',
      I18n.t('frontend.statistics.share'),
      function() {
        return I18n.t(
          'frontend.statistics.ratings_share', {
            percent: Highcharts.numberFormat(this.percentage, 2),
            rating: this.series.name,
            year: this.x
          }
        );
      }, {
        yAxis: {
          max: 100
        }
      }
    );
  });
}

function chart(Highcharts, type, id, data, stacking, yTitle, tooltipFormatter, options) {
  const defaults = {
    chart: {
      renderTo: id,
      type
    },

    title: {
      text: ''
    },

    subtitle: {
      text: ''
    },

    xAxis: {
      categories: data.categories,
      labels: {
        step: 2
      },

      title: {
        enabled: false
      }
    },

    yAxis: {
      title: {
        text: yTitle
      },

      labels: {
        formatter() {
          return this.value;
        }
      }
    },

    tooltip: {
      formatter: tooltipFormatter,
      borderRadius: 0,
      borderWidth: 1,
      shadow: false
    },

    plotOptions: {
      area: {
        stacking,
        lineColor: '#666666',
        lineWidth: 1,
        shadow: false,
        marker: {
          enabled: false,
          lineWidth: 1,
          lineColor: '#666666'
        }
      }
    },

    credits: {
      enabled: false
    },

    legend: {
      borderRadius: 0,
      borderWidth: 0
    },

    // floating: true,
    // align: 'left',
    // verticalAlign: 'top',
    // x: 20,
    // y: 0
    series: data.series
  };

  window[`${id}_chart`] = new Highcharts.Chart($.extend(true, defaults, options || {}));
};
