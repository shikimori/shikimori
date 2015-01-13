(($) ->
  $.fn.extend
    show_more: ->
      @each ->
        $show_more = $(@)
        $hide_more = $show_more.next().find('.hide-more')

        $show_more.on 'click', ->
          $show_more.hide()
          $hide_more.parent().show()
        $hide_more.on 'click', ->
          $show_more.show()
          $hide_more.parent().hide()
) jQuery
