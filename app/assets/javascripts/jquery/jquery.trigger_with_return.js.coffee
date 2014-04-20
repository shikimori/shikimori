(($) ->
  $.fn.extend triggerWithReturn: (name, data) ->
    event = new $.Event(name)
    @trigger event, data
    event.result
) jQuery
