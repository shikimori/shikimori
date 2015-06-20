(($) ->
  $.fn.extend
    spoiler: ->
      @each ->
        $root = $(@)
        return unless $root.hasClass('unprocessed')
        $root.removeClass('unprocessed')

        $label = $root.children('label')
        $content = $label.next()

        $root.on 'spoiler:open', ->
          $label.click()

        $label.on 'click', (e) ->
          return if e.target != $label[0] && !$(@).closest($label).exists()

          $label.hide()
          $content.css(display: 'inline')

          $content.find('.prgrph').each ->
            $(@)
              .addClass('inner-prgrph')
              .removeClass('prgrph')
              .wrap('<div class="spoiler-prgrph"></div>')

          # хак для корректной работы галерей аниме внутри спойлеров
          $content.find('.align-posters').trigger('spoiler:opened')

        $content.on 'click', (e) ->
          if e.target != $content[0] && $(e.target).parent()[0] != $content[0] &&
              !$(e.target).hasClass('inner-prgrph')
            return

          $label.css(display: 'inline')
          $content.hide()
) jQuery
