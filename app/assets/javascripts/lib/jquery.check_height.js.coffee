(($) ->
  $.fn.extend
    check_height: (max_height) ->
      @each ->
        $root = $(@)

        if $root.height() > max_height && !$root.hasClass('shortened')
          $root.addClass('shortened')
          $('<div class="b-height_shortener"><div class="shade"></div><div class="text">развернуть</div></div>')
            .insertAfter($root)
            .on 'click', (e) =>
              height = $root.height()
              $root
                .removeClass('shortened')
                .animated_expand(height)

              $(e.currentTarget).remove()
) jQuery
