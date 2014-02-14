$.tools.tooltip.addEffect 'opacity', ((done) -> # opening animation
  @getTip()
    .css(opacity: 0)
    .show()
    .animate(opacity: 1, top: '-=14', 500, 'easeOutCirc', done)
    .show()

), (done) -> # closing animation
  @getTip().animate opacity: 0, top: '+=14', 250, 'easeInCirc', ->
    $(@).hide()
    done.call()

@tooltip_options =
  effect: 'opacity'
  delay: 150
  predelay: 250
  position: 'top right'
  defaultTemplate: TOOLTIP_TEMPLATE
  onBeforeShow: ->
    $trigger = @getTrigger()
    return if $trigger.hasClass('b-user16') || $trigger.parent().hasClass('b-user16')

    if $trigger.tagName() is 'img' or $trigger.find('img').length
      $trigger.animate opacity: 0.6, 100

  onBeforeHide: ->
    $trigger = @getTrigger()
    return if $trigger.hasClass('b-user16') || $trigger.parent().hasClass('b-user16')

    if $trigger.tagName() is 'img' or $trigger.find('img').length
      $trigger.stop()
      $trigger.animate opacity: 1, 100
