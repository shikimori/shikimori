@TOOLTIP_TEMPLATE = '<div><div class="tooltip-inner"><div class="tooltip-arrow"></div><div class="clearfix"><div class="close"></div><a class="link"></a><div class="tooltip-details"><div class="ajax-loading" title="Загрузка..." /></div></div><div class="dropshadow-top"></div><div class="dropshadow-top-right"></div><div class="dropshadow-right"></div><div class="dropshadow-bottom-right"></div><div class="dropshadow-bottom"></div><div class="dropshadow-bottom-left"></div><div class="dropshadow-left"></div><div class="dropshadow-top-left"></div></div></div>'
@ANIME_TOOLTIP_OPTIONS =
  position: 'top right'
  offset: [-4, 25, -10]
  relative: true
  predelay: 350
  delay: 150

$.tools.tooltip.addEffect 'opacity', ((done) -> # opening animation
  #@getTip()
    #.css(opacity: 0)
    #.show()
    #.animate(opacity: 1, top: '-=14', 500, 'easeOutCirc', done)
    #.show()
  @getTip()
    .css(opacity: 1)
    .show()
    .animate(top: '-=14', 500, 'easeOutCirc', done)
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

    $close = @getTip().find('.close')
    unless $close.data('binded')
      $close
        .data(binded: true)
        .on 'click', => @hide()

      url = ($trigger.data('href') || $trigger.attr('href') || '').replace /\/tooltip/, ''
      if url
        @getTip().find('.link').attr href: url
      if url.match(/\/genres\//)
        @getTip().find('.link').hide()

  onBeforeHide: ->
    $trigger = @getTrigger()

    unless $trigger.hasClass('b-user16') || $trigger.parent().hasClass('b-user16')
      if $trigger.tagName() is 'img' or $trigger.find('img').length
        $trigger.stop()
        $trigger.animate opacity: 1, 100
