$('.slide > div.statistics').live('ajax:success cache:success', function(e, data) {
  if ('mutex' in arguments.callee) {
    return;
  }
  arguments.callee.mutex = true;

  // жанры
  if ($('#genres').length > 0) {
    //_.extend(total.series[0], {
      //dataLabels: {
        //formatter: function() {
          ////return this.y > 5 ? this.y + '%' : null;
          ////return this.y > 5 ? this.point.name.replace('Приключения', 'Прикл.')
                                             ////.replace('Сверхъестественное', 'Сверх.')
                                             ////.replace('Повседневность', 'Повсед.')
                                             ////.replace('Супер сила', 'Супер.')
                                             ////.replace('Фантастика', 'Фан.') : null;
        //},
        //color: 'white',
        //distance: -30
      //},
      //size: '60%'
    //});
    //_.extend(total.series[1], {
      //dataLabels: {
        //formatter: function() {
          ////return this.y > 20 ? '<b>' + this.point.name + '</b>:' + '<b>' + this.y + '</b>' : null;
          ////return '<b>' + this.point.name + '</b>:' + '<b>' + this.y + '%</b>';
          //return '<b>' + this.point.name + '</b>';
        //}
      //},
      //innerSize: '60%'
    //});
    //_.each(total.series[0].data, function(v,k) {
      //v.color = colors[k];
    //});
    //_.each(total.series[1].data, function(v,k) {
      //var brightness = (k%3) / 20;
      //var index = parseInt(k/1);
      //v.color = Highcharts.Color(colors[index]).brighten(brightness).get()
    //});
    //_.each(total.series[1].data, function(v,k) {
      //var brightness = (k%3) / 20;
      //var index = parseInt(k/3);
      //v.color = Highcharts.Color(colors[index]).brighten(brightness).get()
    //});

    chart('pie', 'genres', {
      series: [
        {
          name: 'Жанр',
          data: anime_genres_data,
          dataLabels: {
            formatter: function() { return '<b>' + this.point.name + '</b>'; }
          }
        }
      ]
    }, 'normal', 'Количество', null, {
      plotOptions: {
        pie: {
          shadow: false,
        }
      },
      tooltip: {
        enabled: false
      }
    });

    chart('pie', 'studios', {
      series: [
        {
          name: 'Жанр',
          data: anime_studios_data,
          dataLabels: {
            formatter: function() { return '<b>' + this.point.name + '</b>'; }
          }
        }
      ]
    }, 'normal', 'Количество', null, {
      plotOptions: {
        pie: {
          shadow: false,
        }
      },
      tooltip: {
        enabled: false
      }
    });
  }

  // активность
  //var data = $('#activity').data('stats');
  //chart('area', 'activity', data, 'normal', null, function() {
    //return this.y + ' '+ this.series.name + ' за ' + this.x + ' год';
  //}, {
    //xAxis: {
      //categories: data.categories,
      //labels: {
        //step: Math.ceil(data.categories.length / 14),
      //},
      //title: {
        //enabled: false
      //}
    //},
  //});

  // графики
  $('#scores,#types,#ratings').bar({
    title: function(entry, percent) {
      return percent < 10 ? entry.value : '';
    },
    no_data: function($chart) {
      $chart.html('<p class="stat-sorry">Недостаточно данных</p>');
    }
  });


  function date_diff(date_earlier, date_later) {
    var one_day=1000*60*60*24
    return Math.round((date_later.getTime() - date_earlier.getTime()) / one_day);
  }
  function get_month(date, full_month_name, rod) {
    if (full_month_name) {
      if (rod) {
        var data = ['Января', 'Февраля', 'Марта', 'Апреля', 'Мая', 'Июня', 'Июля', 'Августа', 'Сентября', 'Октября', 'Ноября', 'Декабря'];
      } else {
        var data = ['Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'];
      }
    } else {
      var data = ['Янв', 'Фев', 'Март', 'Апр', 'Май', 'Июнь', 'Июль', 'Авг', 'Сен', 'Окт', 'Нбр', 'Дек'];
    }
    return data[date.getMonth()];
  }
  function get_russian(date) {
    //return date.getDate() + "." + (date.getMonth()+1).toString().replace(/^(\d)$/, '0$1') + "." + date.getFullYear();
    return date.getDate() + " " + get_month(date, true, true);
  }

  $('#activity_inc').bar({
    before: function(stats, options, $chart) {
      // конвертируем даты
      _.each(stats, function(v,k) {
        stats[k].dates = {
          from: new Date(stats[k].name[0]*1000),
          to: new Date(stats[k].name[1]*1000)
        };
      });

      // всякое для тайтлов осей
      options.interval = date_diff(stats[0].dates.from, stats[0].dates.to);
      options.range = date_diff(stats[0].dates.from, stats[stats.length-1].dates.to);
      options.index_label = 0;

      if (options.y_axis) {
        $chart.addClass('y-axis');

        // прозрачные полоски
        var html = [];
        for (var i = 1; i <= 10; i++) {
          html.push('<div class="ruler" style="top: ' + i*10 + '%;"></div>');
        }
        $chart.html(html.join(''));
      }
    },
    title: function(entry) {
      var days = date_diff(entry.dates.from, entry.dates.to);
      return entry.value + " " + p(entry.value, 'час', 'часа', 'часов') +
             " с " + get_russian(entry.dates.from) + " по " + get_russian(entry.dates.to) + " (" + days + " " + p(days, 'день', 'дня', 'дней') + ")";
    },
    //y_axis: function(percent, maximum, original_maximum) {
      //var mult = percent <= 90 ? maximum : original_maximum;

      //if (percent == 100) {
        //return '';
      //}
      //if (percent > 0) {
        //return Math.ceil(percent / 100.0 * mult) + "ч";
      //}
      //return 0;
    //},
    x_axis: function(entry, index, stats, options) {
      // пропуск, пока индекс меньше следующего_допустимого
      if (index < options.index_label) {
        return '';
      }
      var from = entry.dates.from;
      var to = entry.dates.to;

      if (index == 0) {
        options.index_label = 3;
        var label = from.getFullYear();

      } else if (options.prior) {
        if (options.prior.dates.from.getFullYear() != from.getFullYear()) {
          var label = from.getFullYear();
          options.index_label = index+3;

        } else if (options.prior.dates.from.getMonth() != from.getMonth()) {
          var label = get_month(from, options.interval < 8 && index != stats.length-1);
          options.index_label = index+3;

        } else if (options.range <= 120 && entry.value > 0) {
          var label = from.getDate();
          options.index_label = index+2;
        }
      }
      options.prior = entry;
      return label || '';
    },
    no_data: function($chart) {
      $chart.html('<p class="stat-sorry">Недостаточно данных для формирования статистики</p>')
            .removeClass('bar')
            .attr('id', false);
    }
  });

  // выравнение высоты графика активности по высоте с правыми графиками
  var $activity = $('.statistics .activity');

  var mini_charts_margin = parseInt($('.mini-charts').children().last().css('margin-bottom'));
  var auto_height = $('.mini-charts').outerHeight(true) -
                      mini_charts_margin -
                      $('.genres,.studios', '.statistics').outerHeight(true) -
                      $activity.children('.subheadline').outerHeight(true)
  var normalized_height = _.min([_.max([auto_height, 180]), 240]);

  $('#activity_inc').css('height', normalized_height);

  // когда график активности недостаточно высокий, то сдвигаем его вниз до края правых графиков
  if (auto_height > normalized_height + mini_charts_margin) {
    $activity.css('padding-top', auto_height - normalized_height - mini_charts_margin + 10);
  }

  // долбаная опера
  if ($.browser.opera) {
    $activity.hide();
    _.delay(function() {
      $activity.show();
    });
  }
});
