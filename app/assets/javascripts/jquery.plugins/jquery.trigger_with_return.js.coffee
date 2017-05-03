(($) ->
  $.fn.extend trigger_with_return: (name, data) ->
    event = new $.Event(name)
    @trigger event, data
    event.result
) jQuery
