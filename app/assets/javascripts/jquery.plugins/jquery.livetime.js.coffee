I18N_TIME_FORMATS =
  ru: 'D MMMM YYYY, H:mm:ss'
  en: 'MMMM Do YYYY, h:mm:ss a'

(($) ->
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
          format = I18N_TIME_FORMATS[I18n.locale] || I18N_TIME_FORMATS['en']
          $(@).attr title: time.format(format)

  update_times = ->
    $('time').each -> update_time @

  update_time = (node) ->
    $node = $(node)
    timeinfo = get_timeinfo($node)
    new_value = timeinfo.moment.fromNow()

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
    timeinfo.moment = if moment().isBefore(node_time) then moment() else node_time
    timeinfo.value = $node.text()

    $node.data timeinfo: timeinfo

    timeinfo

) jQuery
