(($) ->
  $.fn.extend
    spoiler: ->
      @each ->
        $label = $(@).children('label')
        $content = $label.next()

        $label.on 'click', (e) ->
          return if e.target != $label[0]
          $label.hide()
          $content.css(display: 'inline')

        $content.on 'click', (e) ->
          return if e.target != $content[0] && $(e.target).parent()[0] != $content[0]
          $label.css(display: 'inline')
          $content.hide()
) jQuery
