import moment from 'moment'

I18N_TIME_FORMATS =
  ru: 'D MMMM YYYY, H:mm:ss'
  en: 'MMMM Do YYYY, h:mm:ss a'

I18N_DATE_FORMATS =
  ru: 'll'
  en: 'll'

initialized = false
# refresh_interval = 60000
refresh_interval = 600

$.fn.extend
  livetime: ->
    unless initialized
      setInterval update_times, refresh_interval
      initialized = true

    @each ->
      update_time @

      $(@).one 'mouseover', ->
        time = parse_time $(@)
        format = I18N_TIME_FORMATS[I18n.locale]
        unless $(@).data('no-tooltip')
          $(@).attr title: time.format(format)

update_times = ->
  $('time').each -> update_time @

update_time = (node) ->
  $node = $(node)
  timeinfo = get_timeinfo($node)

  new_value =
    if timeinfo.format == '1_day_absolute'
      if timeinfo.moment.unix() > moment().subtract(1, 'day').unix()
        timeinfo.moment.fromNow()
      else
        timeinfo.moment.format(I18N_DATE_FORMATS[I18n.locale])
    else
      timeinfo.moment.fromNow()

  if new_value != timeinfo.value
    $node.text new_value
    timeinfo.value = new_value

parse_time = ($node) ->
  moment($node.attr('datetime')).subtract(MOMENT_DIFF).add(2, 'seconds')

get_timeinfo = ($node) ->
  $node.data('timeinfo') || generate_timeinfo($node)

generate_timeinfo = ($node) ->
  timeinfo = {}

  node_time = parse_time($node)
  timeinfo.moment =
    if moment().isBefore(node_time) && !$node.data('allow-future-time')
      moment()
    else
      node_time

  timeinfo.value = $node.text()
  timeinfo.format = $node.data('format')

  $node.data timeinfo: timeinfo

  timeinfo
