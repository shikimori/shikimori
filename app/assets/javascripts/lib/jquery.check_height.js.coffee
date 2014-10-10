(($) ->
  $.fn.extend
    check_height: (max_height, without_shade = false) ->
      @each ->
        $root = $(@)

        if $root.height() > max_height && !$root.hasClass('shortened')
          $root.addClass('shortened')
          html = if without_shade
            '<div class="b-height_shortener"><div class="expand">развернуть</div></div>'
          else
            '<div class="b-height_shortener"><div class="shade"></div><div class="expand">развернуть...</div></div>'

          $(html)
            .insertAfter($root)
            .on 'click', (e) =>
              height = $root.height()
              $root
                .removeClass('shortened')
                .animated_expand(height)

              $(e.currentTarget).remove()
) jQuery
