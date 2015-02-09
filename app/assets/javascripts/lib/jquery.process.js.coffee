(($) ->
  $.fn.extend
    process: ->
      @each ->
        process_current_dom @
) jQuery
