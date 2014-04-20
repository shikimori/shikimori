/*
 * jQuery statistics bar plugin
 *
 * Copyright (c) 2012 Andrey Sidorov
 * licensed under MIT license.
 *
 * https://github.com/morr/...
 *
 * Version: 0.1
 */
(function($) {
  $.fn.extend({
    bar: function(options) {
      return this.each(function() {
        var $chart = $(this);

        switch ($chart.data('bar')) {
          case 'horizontal':
            simple_bar($chart, _.extend(options || {}, { type: 'horizontal' }));
            break;

          case 'vertical':
            simple_bar($chart, _.extend(options || {}, { type: 'vertical' }));
            break;

          case 'vertical-complex':
            complex_bar($chart, _.extend(options || {}, { type: 'vertical' }));
            break;
        }
      });
    }
  });

  // горизонтальный график
  function simple_bar($chart, options) {
    $chart.addClass('bar simple '+options.type);

    var stats = $chart.data('stats');
    if (!stats || !stats.length) {
      if (options.no_data) {
        options.no_data($chart);
      }
      return;
    }

    var maximum = _.max(stats, function(v,k) { return v.value; }).value;
    var flattened = false;

    if ($chart.data('flattened')) {
      var values = _.select(_.map(stats, function(v,k) { return v.value; }),
        function(v) { return v > 0 && v != maximum; }
      );
      var average =  _.reduce(values, function(memo, num){ return memo + num; }, 0) / values.length;
      if (maximum > average * 5) {
        var original_maximum = maximum;
        maximum = average * 3;
        flattened = true;
      }
    }

    // колбек перед началом создания графика
    if (options.before) {
      options.before(stats, options, $chart);
    }

    if (options.y_axis) {
      var html = [];
      for (var i = -1; i < 10; i++) {
        var percent = i != -1 ? (100 - i*10) : 0;
        html.push("<div class='y_label' style='top: " + (100-percent) + "%;'>" + options.y_axis(percent, maximum, original_maximum) + "</div>");
      }
      $chart.append(html.join(''));
    }

    _.each(stats, function(entry, index) {
      var percent = parseInt(entry.value / maximum * 100 * 100) * 0.01;
      if (flattened) {
        percent *= 0.9;

        // до 90% обычная шкала, а затем в зависимости от приближения к максимальному значению
        if (percent > 100) {
          percent = 90 + entry.value * 10.0 / original_maximum;
        }
      }

      var color = "s0";
      if (percent <= 80 && percent > 60) {
        color = "s1";
      } else if (percent <= 60 && percent > 30) {
        color = "s2";
      } else if (percent <= 30) {
        color = "s3";
      }

      var dimension = options.type == 'vertical' ? 'height' : 'width';


      if (options.x_axis) {
        var x_axis = options.x_axis(entry, index, stats, options);
      } else {
        var x_axis = entry.name;
      }
      if (options.title) {
        var title = options.title(entry, percent);
      }
      $chart.append("<div class='line'><div class='x_label'>" + x_axis
        + "</div><div class='bar-container'><div class='bar " + color + (percent > 0 ? ' min' : '') + "' style='" + dimension+ ": " + percent + "%'" + (title ? " title='"+title+"'" : '') + ">"
        + (percent > 6 ? "<div class='value" + (percent < 10 ? " narrow" : "") + (entry.value > 100 ? " mini" : "") + "'>" + entry.value + "</div>" : "")
        + "</div></div></div>");
    });

  }

  // многослойный вертикальный график
  function complex_bar($chart, options) {
    $chart.addClass('bar complex '+options.type);

    var stats = $chart.data('stats');
    var categories = stats.categories;
    var series = stats.series;

    //var maximum = _.max(_.max(series, function(data) {
      //return _.max(data.data);
    //}).data);

    var aggr_data = [];
    _.each(_.first(series).data, function() {
      aggr_data.push(0);
    });

    _.each(series, function(serie) {
      for (var i = 0; i < serie.data.length; i++) {
        aggr_data[i] += serie.data[i];
      }
    });
    var maximum = _.max(aggr_data);
    var another_maximum_index = -1;
    var another_maximum = _.max(_.select(aggr_data, function(v) { return v != maximum; }));

    if (another_maximum * 2 < maximum) {
      another_maximum_index = _.indexOf(aggr_data, maximum);
      var tmp = maximum;
      maximum = another_maximum;
      another_maximum = tmp;
    }

    var html = [];
    _.each(aggr_data, function(v, index) {
      html.push("<div class='line'><div class='bar-container'>");
      var tmp = [];
      _.each(series, function(serie, serie_index) {
        var percent = parseInt(serie.data[index] / maximum * 100 * 100) * 0.01;
        if (another_maximum_index != -1 && index == another_maximum_index) {
          percent *= maximum / another_maximum;
        }

        tmp.push("<div class='bar" + (percent > 0 ? ' min' : '') + " s"+ serie_index + "' style='height: " + percent + "%'></div>");
      });
      html.push(tmp.reverse().join(''));
      html.push("</div></div>");
    });
    // прозрачные горизонтальные полоски
    for (var i = 1; i <= 15; i++) {
      html.push('<div class="ruler" style="bottom: ' + i*20 + 'px;"></div>');
    }
    $chart.html(html.join(''));
  }
})(jQuery);
