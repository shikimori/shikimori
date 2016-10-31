using 'Styles'
class Styles.BodyBackground extends View
  REGEXP = /\/\* AUTO=body_background.*?body { background: url\((.+?)\)(.*)}.*/

  initialize: ->
    @css_template = @$root.data 'css_template'
    @input = @$('#body_background_input')[0]
    @repeat = @$('#body_background_repeat')[0]
    @fixed = @$('#body_background_fixed')[0]
    @left = @$('#body_background_left')[0]
    @top = @$('#body_background_top')[0]
    @right = @$('#body_background_right')[0]
    @bottom = @$('#body_background_bottom')[0]

    @$('input').on 'change', @_sync_state
    @$('.prepared-backgrounds li').on 'click', @_prepared_background

  update: (css) ->
    [
      @background_url,
      @is_repeat,
      @is_fixed,
      @is_left,
      @is_top,
      @is_right,
      @is_bototm
    ] = @_extract(css)

    @input.value = @background_url || ''
    @repeat.checked = @is_repeat
    @fixed.checked = @is_fixed
    @left.checked = @is_left
    @top.checked = @is_top
    @right.checked = @is_right
    @bottom.checked = @is_bottom

  _sync_state: =>
    @background_url = @input.value
    @is_repeat = @repeat.checked
    @is_fixed = @fixed.checked
    @is_left = @left.checked
    @is_top = @top.checked
    @is_right = @right.checked
    @is_bottom = @bottom.checked

    @trigger 'component:update', [REGEXP, @_compile()]

  _prepared_background: (e) =>
    @input.value = $(e.target).data('background')
    @repeat.checked = true
    @fixed.checked = false
    @left.checked = false
    @top.checked = false
    @right.checked = false
    @bottom.checked = false

    @_sync_state()

  _extract: (css) ->
    matches = css.match(REGEXP)

    if matches
      [
        matches[1],
        matches[2].match(/ repeat\b/, '')
        matches[2].match(/ fixed\b/, '')
        matches[2].match(/ left\b/, '')
        matches[2].match(/ top\b/, '')
        matches[2].match(/ right\b/, '')
        matches[2].match(/ bottom\b/, '')
      ]
    else
      []

  _compile: ->
    if @background_url
      options = [if @is_repeat then 'repeat' else 'no-repeat']
      options.push 'fixed' if @is_fixed
      options.push 'left' if @is_left
      options.push 'top' if @is_top
      options.push 'right' if @is_right
      options.push 'bottom' if @is_bottom
      css ="url(#{@background_url}) #{options.join ' '}"

      @css_template.replace(/%s/, css)

    else
      ''
