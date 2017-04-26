(($) ->
  $.fn.extend
    # анимированное раскрытие элемента
    animated_expand: (start_heigth = 0) ->
      @each ->
        $node = $(@)
        finish_collapse $node
        $node.show().css(height: '')

        height = $node.outerHeight()
        $node
          .addClass('animated-overflow')
          .css(height: "#{start_heigth}px")

        (->
          $node
            .addClass('animated-height')
            .css(height: height)
            .data(animated_direction: 'expand')
        ).delay()

        (->
          if $node.data('animated_direction') == 'expand'
            finish_expand $node
        ).delay(500)

    # анимированное скрытие элемента
    animated_collapse: () ->
      @each ->
        $node = $(@)
        finish_expand $node

        height = $node.outerHeight()
        $node
          .css(height: "#{height}px")
          .addClass('animated-overflow')

        (->
          $node
            .addClass('animated-height')
            .css(height: 0)
            .data(animated_direction: 'collapse')
        ).delay()

        (->
          if $node.data('animated_direction') == 'collapse'
            finish_collapse $node
        ).delay(500)

  finish_collapse = ($node) ->
    $node
      .css(height: '')
      .removeClass('animated-height')
      .removeClass('animated-overflow').hide()

  finish_expand = ($node) ->
    $node
      .css(height: '')
      .removeClass('animated-height')
      .removeClass('animated-overflow')
) jQuery
