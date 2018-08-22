$.fn.extend rateable: ->
  @each ->
    $stars = $('.stars-container', @)
    $hover = $('.hover', @)
    $hoverable_trigger = $('.hoverable-trigger', @)

    $score = $('.score', @)
    $score_value = $('.score-value', @)
    $score_notice = $('.score-notice', @)

    notices = $(@).data('notices')
    input_selector = $(@).data('input_selector')
    with_input = !!input_selector

    initial_score = parseInt($score_value.text()) || 0
    new_score = null

    $hoverable_trigger.on 'mousemove', (e) ->
      offset = $(e.target).offset().left
      raw_score = (e.clientX - offset) * 10.0 / $stars.width()
      new_score = if raw_score > 0.5
        [Math.floor(raw_score) + 1, 10].min()
      else
        0

      $score_notice.html(notices[new_score] || '&nbsp;')
      $hover.attr(class: "#{without_score $hover} score-#{new_score}")
      $score_value
        .html(new_score)
        .attr(class: "#{without_score $score_value} score-#{new_score}")

    $hoverable_trigger.on 'mouseover', (e) ->
      $score.addClass 'hovered'

    $hoverable_trigger.on 'mouseout', (e) ->
      $score.removeClass 'hovered'
      $score_notice.html(notices[initial_score] || '&nbsp;')
      $hover.attr(class: without_score $hover)
      $score.attr(class: "#{without_score $score} score-#{initial_score}")
      $score_value
        .attr(class: "#{without_score $score_value} score-#{initial_score}")
        .html(initial_score)

    $hoverable_trigger.on 'click', (e) ->
      if with_input
        initial_score = new_score
        $(@).trigger('mouseout')
        $(@).closest('form').find(input_selector).val(new_score)

      $(@).trigger('rate:change', new_score)

without_score = ($node) ->
  $node.attr('class').replace(/\s?score-\d+/, '')
