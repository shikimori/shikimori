(($) ->
  $.fn.extend
    yellow_fade: ->
      @each ->
        $root = $(@)

        return if $root.hasClass 'yellow-fade'
        $root.addClass('yellow-fade')

        (->
          $root.addClass('yellow-fade-animated')
          (->
            $root.removeClass('yellow-fade yellow-fade-animated')
          ).delay(1000)
        ).delay(50)
) jQuery
