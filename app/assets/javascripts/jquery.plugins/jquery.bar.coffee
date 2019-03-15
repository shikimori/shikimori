###
# jQuery statistics bar plugin
#
# Copyright (c) 2012 Andrey Sidorov
# licensed under MIT license.
#
# https://github.com/morr/...
#
# Version: 0.1
# TODO: refactor
###

$.fn.extend bar: (options) ->
  @each ->
    $chart = $(this)

    switch $chart.data('bar')
      when 'horizontal'
        simple_bar $chart, Object.add(options || {}, type: 'horizontal')

      when 'vertical'
        simple_bar $chart, Object.add(options || {}, type: 'vertical')

      # when 'vertical-complex'
        # complex_bar $chart, Object.add(options || {}, type: 'vertical')

      else
        throw 'unknown bar-type: ' + $chart.data('bar')

# горизонтальный график
simple_bar = ($chart, options) ->
  $chart.addClass "bar simple #{options.type}"

  field = options.field || 'value'
  stats = $chart.data('stats')
  intervals_count = $chart.data('intervals_count')

  maximum = stats.max((v, k) -> v[field])?[field]

  flattened = false

  if !stats || !stats.length
    options.no_data $chart if options.no_data
    return

  if $chart.data('flattened')
    values = stats
      .map (v, k) ->
        v[field]
      .filter (v) ->
        v > 0 && v != maximum

    average = values.average()

    if maximum > average * 5 && average > 0
      original_maximum = maximum
      maximum = average * 3
      flattened = true

  # колбек перед началом создания графика
  options.before stats, options, $chart if options.before

  if options.y_axis
    html = []
    i = -1

    while i < 10
      percent = if i != -1 then 100 - (i * 10) else 0
      html.push(
        "<div class='y_label' style='top: #{100 - percent}%;'>" +
          options.y_axis(percent, maximum, original_maximum) +
        '</div>'
      )
      i++

    $chart.append html.join('')

  if options.filter
    stats = stats.filter (entry) ->
      percent = parseInt(entry[field] / maximum * 100 * 100) * 0.01
      options.filter entry, percent

  stats.forEach (entry, index) ->
    percent = parseInt(entry[field] / maximum * 100 * 100) * 0.01

    if flattened
      percent *= 0.9
      # до 90% обычная шкала,
      # а затем в зависимости от приближения к максимальному значению
      percent = 90 + entry[field] * 10.0 / original_maximum if percent > 100

    color =
      if percent <= 80 && percent > 60
        's1'
      else if percent <= 60 && percent > 30
        color = 's2'
      else if percent <= 30
        color = 's3'
      else
        's0'

    dimension =
      if options.type == 'vertical'
        'height'
      else
        'width'

    x_axis =
      if options.x_axis
        options.x_axis entry, index, stats, options
      else
        entry.name

    title =
      if options.title
        options.title entry, percent
      else
        entry[field]

    value =
      if percent > 25 ||
          (percent > 17 && entry[field] < 1000) ||
          (percent > 10 && entry[field] < 100) ||
          (percent > 5 && entry[field] < 10)
        entry[field]
      else
        ''

    style =
      if options.type == 'vertical'
        "style='width: #{100.0 / intervals_count}%;'"
      else
        ''

    value_classes = ['value']
    value_classes.push 'narrow' if percent < 10
    value_classes.push 'mini' if entry[field] > 99

    $chart.append(
      "<div class='line'" +
      (if options.type == 'vertical' then ' style="width: ' + (100.0 / (intervals_count)) + '%;"' else '') +
      "><div class='x_label'>" + x_axis +
      "</div><div class='bar-container'><div class='bar " + color +
      (if percent > 0 then ' min' else '') + "' style='" + dimension + ': ' +
      percent + "%'" + " title='" + (title || entry[field]) + "'>" +
      "<div class='#{value_classes.join(' ')}'>" +
      value + '</div>' +
      '</div></div></div>'
    )

# многослойный вертикальный график
# complex_bar = ($chart, options) ->
  # $chart.addClass 'bar complex ' + options.type
  # stats = $chart.data('stats')
  # categories = stats.categories
  # series = stats.series
  # aggr_data = []
  # _.each _.first(series).data, ->
    # aggr_data.push 0
    # return
  # _.each series, (serie) ->
    # i = 0
    # while i < serie.data.length
      # aggr_data[i] += serie.data[i]
      # i++
    # return
  # maximum = _.max(aggr_data)
  # another_maximum_index = -1
  # another_maximum = _.max(_.select(aggr_data, (v) ->
    # v != maximum
  # ))
  # if another_maximum * 2 < maximum
    # another_maximum_index = _.indexOf(aggr_data, maximum)
    # tmp = maximum
    # maximum = another_maximum
    # another_maximum = tmp
  # html = []
  # _.each aggr_data, (v, index) ->
    # `var tmp`
    # html.push '<div class=\'line\'><div class=\'bar-container\'>'
    # tmp = []
    # _.each series, (serie, serie_index) ->
      # percent = parseInt(serie.data[index] / maximum * 100 * 100) * 0.01
      # if another_maximum_index != -1 && index == another_maximum_index
        # percent *= maximum / another_maximum
      # tmp.push '<div class=\'bar' + (if percent > 0 then ' min' else '') + ' s' + serie_index + '\' style=\'height: ' + percent + '%\'></div>'
      # return
    # html.push tmp.reverse().join('')
    # html.push '</div></div>'
    # return
  # # прозрачные горизонтальные полоски
  # i = 1
  # while i <= 15
    # html.push '<div class="ruler" style="bottom: ' + i * 20 + 'px;"></div>'
    # i++
  # $chart.html html.join('')
  # return

# # ORIGINAL JS
# function complex_bar($chart, options) {
  # $chart.addClass('bar complex '+options.type);

  # var stats = $chart.data('stats');
  # var categories = stats.categories;
  # var series = stats.series;

  # //var maximum = _.max(_.max(series, function(data) {
    # //return _.max(data.data);
  # //}).data);

  # var aggr_data = [];
  # _.each(_.first(series).data, function() {
    # aggr_data.push(0);
  # });

  # _.each(series, function(serie) {
    # for (var i = 0; i < serie.data.length; i++) {
      # aggr_data[i] += serie.data[i];
    # }
  # });
  # var maximum = _.max(aggr_data);
  # var another_maximum_index = -1;
  # var another_maximum = _.max(_.select(aggr_data, function(v) { return v != maximum; }));

  # if (another_maximum * 2 < maximum) {
    # another_maximum_index = _.indexOf(aggr_data, maximum);
    # var tmp = maximum;
    # maximum = another_maximum;
    # another_maximum = tmp;
  # }

  # var html = [];
  # _.each(aggr_data, function(v, index) {
    # html.push("<div class='line'><div class='bar-container'>");
    # var tmp = [];
    # _.each(series, function(serie, serie_index) {
      # var percent = parseInt(serie.data[index] / maximum * 100 * 100) * 0.01;
      # if (another_maximum_index != -1 && index == another_maximum_index) {
        # percent *= maximum / another_maximum;
      # }

      # tmp.push("<div class='bar" + (percent > 0 ? ' min' : '') + " s"+ serie_index + "' style='height: " + percent + "%'></div>");
    # });
    # html.push(tmp.reverse().join(''));
    # html.push("</div></div>");
  # });
  # // прозрачные горизонтальные полоски
  # for (var i = 1; i <= 15; i++) {
    # html.push('<div class="ruler" style="bottom: ' + i*20 + 'px;"></div>');
  # }
  # $chart.html(html.join(''));
# }
