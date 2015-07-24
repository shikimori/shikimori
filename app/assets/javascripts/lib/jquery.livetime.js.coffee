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

    timeinfo = $(node).data('timeinfo') ||
      moment: moment($node.data('momentjs-time'))
      value: $node.text()

    new_value = timeinfo.moment.fromNow()

    if new_value != timeinfo.value
      $node.text new_value
      timeinfo.value = new_value

) jQuery
