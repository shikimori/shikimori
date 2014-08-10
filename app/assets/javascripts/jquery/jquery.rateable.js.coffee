(($) ->
  $.fn.extend rateable: ->
    @each ->
      $stars = $('.stars-container', @)
      $hover = $('.hover', @)

      $score = $('.score', @)
      $text_score = $('.text-score', @)
      $score_notice = $('.score-notice', @)

      notices = $(@).data 'notices'

      initial_score = parseInt($text_score.text()) || 0
      initial_hover_class = $hover.attr 'class'
      initial_text_class = $text_score.attr 'class'
      new_score = null

      $stars.on 'mousemove', (e) ->
        offset = $(e.target).offset().left
        raw_score = (e.clientX - offset) * 10.0 / $stars.width()
        new_score = if raw_score > 0.5
          Math.floor(raw_score) + 1
        else
          0

        $score_notice.html(notices[new_score])
        $hover.attr(class: "#{initial_hover_class} score-#{new_score}")
        $text_score
          .html(new_score)
          .attr(class: "#{initial_text_class} score-#{new_score}")

      $stars.on 'mouseover', (e) ->
        $score.addClass 'hovered'

      $stars.on 'mouseout', (e) ->
        $score.removeClass 'hovered'
        $score_notice.html(notices[initial_score])
        $hover.attr(class: initial_hover_class)
        $text_score
          .html(initial_score)
          .attr(class: initial_text_class)

) jQuery
