// TODO: refactor to view object
$.fn.extend({
  bar(options) {
    return this.each(function() {
      const $chart = $(this);

      switch ($chart.data('bar')) {
        case 'horizontal':
          simpleBar($chart, Object.add(options || {}, { type: 'horizontal' }));
          break;

        case 'vertical':
          simpleBar($chart, Object.add(options || {}, { type: 'vertical' }));
          break;

        // when 'vertical-complex'
          // complex_bar $chart, Object.add(options || {}, type: 'vertical')

        default:
          throw 'unknown bar-type: ' + $chart.data('bar'); // eslint-disable-line no-throw-literal
      }
    });
  }
});

// горизонтальный график
function simpleBar($chart, options) {
  let originalMaximum;
  let percent;

  $chart.addClass(`bar simple ${options.type}`);

  const field = options.field || 'value';
  let stats = $chart.data('stats');

  if (!stats || !stats.length) {
    if (options.noData) {
      options.noData($chart);
    }
    return;
  }

  const intervalsCount = $chart.data('intervals_count');
  let maximum = stats.max((v, _k) => v[field])?.[field];
  let flattened = false;

  if ($chart.data('flattened')) {
    const values = stats
      .map((v, _k) => v[field])
      .filter(v => (v > 0) && (v !== maximum));

    const average = values.average();

    if ((maximum > (average * 5)) && (average > 0)) {
      originalMaximum = maximum;
      maximum = average * 3;
      flattened = true;
    }
  }

  // колбек перед началом создания графика
  if (options.before) {
    options.before(stats, options, $chart);
  }

  if (options.y_axis) {
    const html = [];
    let i = -1;

    while (i < 10) {
      percent = i !== -1 ? 100 - (i * 10) : 0;
      html.push(
        `<div class='y_label' style='top: ${100 - percent}%;'>` +
          options.y_axis(percent, maximum, originalMaximum) +
        '</div>'
      );
      i += 1;
    }

    $chart.append(html.join(''));
  }

  if (options.map) {
    stats = stats.map(entry => options.map(entry));
  }

  if (options.filter) {
    stats = stats.filter(entry => {
      percent = parseInt((entry[field] / maximum) * 100 * 100) * 0.01;
      return options.filter(entry, percent);
    });
  }

  stats.forEach((entry, index) => {
    percent = parseInt((entry[field] / maximum) * 100 * 100) * 0.01;

    if (flattened) {
      percent *= 0.9;
      // до 90% обычная шкала,
      // а затем в зависимости от приближения к максимальному значению
      if (percent > 100) {
        percent = 90 + ((entry[field] * 10.0) / originalMaximum);
      }
    }

    const color = colorByPercent(percent);

    const dimension =
      options.type === 'vertical' ?
        'height' :
        'width';

    const xAxis =
      options.xAxis ?
        options.xAxis(entry, index, stats, options) :
        entry.name;

    const title =
      options.title ?
        options.title(entry, percent) :
        entry[field];

    const value =
      (percent > 25) ||
          ((percent > 17) && (entry[field] < 1000)) ||
          ((percent > 10) && (entry[field] < 100)) ||
          ((percent > 5) && (entry[field] < 10)) ?
        entry[field] :
        '';

    const cssStyles =
      options.type === 'vertical' ?
        ` style="width: ${100.0 / intervalsCount}%;"` :
        '';

    const cssClasses = [
      'value',
      percent < 10 ? 'narrow' : null,
      entry[field] > 99 ? 'mini' : null
    ].compact();

    $chart.append(
      `<div class="line"${cssStyles}>` +
        `<div class="x_label">${xAxis}</div>` +
        '<div class="bar-container">' +
          `<div class="bar ${color}${percent > 0 ? ' min' : ''}"` +
            ` style="${dimension}: ${percent}%" title="${title || entry[field]}">` +
            `<div class="${cssClasses.join(' ')}">${value}</div>` +
          '</div>' +
        '</div>' +
      '</div>'
    );
  });
}

function colorByPercent(percent) {
  if (percent <= 80 && percent > 60) { return 's1'; }
  if (percent <= 60 && percent > 30) { return 's2'; }
  if (percent <= 30) { return 's3'; }
  return 's0';
}
