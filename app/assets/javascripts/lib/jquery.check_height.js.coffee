(($) ->
  $.fn.extend
    check_height: (max_height, without_shade = false, collapsed_height) ->
      collapsed_height ?= Math.round max_height * 2.0 / 3

      @each ->
        $root = $(@)

        if $root.height() > max_height && !$root.hasClass('shortened')
          margin_bottom = parseInt $root.css('margin-bottom')
          $root
            .addClass('shortened')
            .css(height: collapsed_height)

          html = if without_shade
            '<div class="b-height_shortener" style="margin-bottom: '+margin_bottom+'px"><div class="expand">развернуть</div></div>'
          else
            '<div class="b-height_shortener" style="margin-bottom: '+margin_bottom+'px"><div class="shade"></div><div class="expand">развернуть...</div></div>'

          $(html)
            .insertAfter($root)
            .on 'click', (e) =>
              height = $root.height()
              $root
                .removeClass('shortened')
                .animated_expand(height)

              $(e.currentTarget).remove()
) jQuery
