using 'Styles'
class Styles.PageBackgroundColor extends View
  REGEXP = /\/\* AUTO=page_background_color.*?rgba\((\d+), (\d+), (\d+), (\d+).*[\r\n]?/

  ZERO_OPACITY = 255
  DEFAULT_OPACITIES = [ZERO_OPACITY, ZERO_OPACITY, ZERO_OPACITY, 1]

  initialize: ->
    @slider = @$('.range-slider')[0]
    @css_template = @$root.data 'css_template'

    @init_promise = require.ensure [], (require) =>
      @_init_slider require('nouislider')

  update: (css) ->
    @init_promise.then =>
      @opacities = @_extract(css)
      opacity = ZERO_OPACITY - @opacities.first()
      @_silenced => @slider.noUiSlider.set opacity

  _init_slider: (noUiSlider) ->
    noUiSlider.create @slider,
      range:
        min: 0
        max: 12
      start: 0

    @_silenced => @slider.noUiSlider.on 'update', @_debounced_sync

  _extract: (css) ->
    matches = css.match(REGEXP)

    if matches
      matches[1..4].map (v) -> parseFloat(v).round()
    else
      DEFAULT_OPACITIES

  _debounced_sync: =>
    @_sync_lambda ||= debounce(100, @_sync_state)
    @_sync_lambda() unless @is_silenced

  _sync_state: =>
    opacity = ZERO_OPACITY - parseFloat(@slider.noUiSlider.get()).round()
    @opacities = [opacity, opacity, opacity, @opacities[3]]
    @trigger 'component:update', [REGEXP, @_compile()]

  _compile: ->
    if @opacities[0] != ZERO_OPACITY
      @css_template
        .replace(/%d/, @opacities[0])
        .replace(/%d/, @opacities[1])
        .replace(/%d/, @opacities[2])
        .replace(/%d/, @opacities[3])
    else
      ''

  _silenced: (lambda) ->
    @is_silenced = true
    lambda()
    @is_silenced = false
