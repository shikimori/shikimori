using 'Styles'
class Styles.PageBackgroundColor extends View
  REGEXP = /.*GENERATED: page_background_color[\s\S]*?rgba\((\d+), (\d+), (\d+), (\d+)[\s\S]*?GENERATED: \/page_background_color.*/

  ZERO_OPACITY = 255
  DEFAULT_OPACITIES = [ZERO_OPACITY, ZERO_OPACITY, ZERO_OPACITY, 1]

  initialize: (@$css) ->
    @slider = @$('.range-slider')[0]
    @css_template = @$root.data 'css_template'
    @opacities = @_extract_opacities()

    @_init_slider()

  update: ->

  _extract_opacities: ->
    matches = @$css.val().match(REGEXP)

    if matches
      matches[1..4].map (v) -> parseFloat(v).round()
    else
      DEFAULT_OPACITIES

  _init_slider: ->
    noUiSlider.create @slider,
      range:
        min: 0
        max: 12
      start: ZERO_OPACITY - @opacities.first()

    @slider.noUiSlider.on 'update', @_slider_update.debounce(100)

  _slider_update: (value) =>
    unless @first_update
      @first_update = true
      return

    opacity = ZERO_OPACITY - parseFloat(value).round()
    @opacities = [opacity, opacity, opacity, @opacities[3]]
    @_update_css()

  _update_css: ->
    css = @$css.val()

    if css.match(REGEXP)
      @$css.val css.replace(REGEXP, @_compile())
    else
      @$css.val @_compile() + "\n\n" + css

    @trigger 'component:update'

  _compile: ->
    @css_template
      .replace(/%d/, @opacities[0])
      .replace(/%d/, @opacities[1])
      .replace(/%d/, @opacities[2])
      .replace(/%d/, @opacities[3])
