(($) ->
  $.fn.extend
    view: (value) ->
      if value
        @data view_object: value
      else
        @data 'view_object'

    shiki: (value) ->
      console.warn("$(node).shiki() is deprecated!")

      if value
        @data view_object: value
      else
        @data 'view_object'
) jQuery
