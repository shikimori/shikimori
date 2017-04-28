(($) ->
  $.fn.extend
    yellow_fade: ->
      @each ->
        $root = $(@)

        return if $root.hasClass 'yellow-fade'
        $root.addClass('yellow-fade')

        delay(50).then ->
          $root.addClass('yellow-fade-animated')
          delay(1000).then ->
            $root.removeClass('yellow-fade yellow-fade-animated')
) jQuery
