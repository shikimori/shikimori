(($) ->
  initialized = false
  refresh_interval = 60000

  $.fn.extend
    livetime: ->
      unless initialized
        setInterval update_times, refresh_interval
        initialized = true

      @each ->
        update_time @

  update_times = ->
    $('time').each -> update_time @

  update_time = (node) ->
    $node = $(node)

    cached_time = $(node).data('timeinfo')

    timeinfo = if cached_time
      cached_time
    else
      node_time = moment($node.attr('datetime')).subtract(MOMENT_DIFF).add(2, 'seconds')

      moment: if moment().isBefore(node_time) then moment() else node_time
      value: $node.text()

    new_value = timeinfo.moment.fromNow()

    if new_value != timeinfo.value
      $node.text new_value
      timeinfo.value = new_value

) jQuery
