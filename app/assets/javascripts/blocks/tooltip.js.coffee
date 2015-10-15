@TOOLTIP_TEMPLATE = '<div>
  <div class="tooltip-inner">
    <div class="tooltip-arrow"></div>
    <div class="clearfix">
      <div class="close"></div>
      <div class="tooltip-details">
        <div class="ajax-loading" title="Загрузка..." />
      </div>
    </div>
    <div class="dropshadow-top"></div>
    <div class="dropshadow-top-right"></div>
    <div class="dropshadow-right"></div>
    <div class="dropshadow-bottom-right"></div>
    <div class="dropshadow-bottom"></div>
    <div class="dropshadow-bottom-left"></div>
    <div class="dropshadow-left"></div>
    <div class="dropshadow-top-left"></div>
  </div>
</div>'

$.tools.tooltip.addEffect 'opacity', (done) ->
  @getTip()
    .css(opacity: 1)
    .show()
    .animate(top: '-=14', 500, 'easeOutCirc', done)

, (done) ->
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

    # удаляем тултипы у всего внутри
    $trigger.find('[title]').attr(title: '')

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

@ANIME_TOOLTIP_OPTIONS = $.extend {}, @tooltip_options,
  offset: [-4, 10, -10]
  position: 'top right'
  predelay: 350
