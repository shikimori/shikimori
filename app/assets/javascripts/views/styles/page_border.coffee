using 'Styles'
class Styles.PageBorder extends View
  REGEXP = /.*GENERATED: page_border[\s\S]*? { display: (\w+); }[\s\S]*?GENERATED: \/page_border.*/

  BORDER_STYLE =
    true: 'block'
    false: 'none'

  initialize: ->
    @css_template = @$root.data 'css_template'
    @$input = @$('input')
    @input = @$input[0]

    @$input.on 'change', @_sync_state

  update: (css) ->
    @has_border = @_extract(css)
    @input.checked = @has_border

  _extract: (css) ->
    matches = css.match(REGEXP)

    if matches && matches[1] == BORDER_STYLE['true']
      true
    else
      false

  _sync_state: =>
    @has_border = @input.checked
    @trigger 'component:update', [REGEXP, @_compile()]

  _compile: ->
    @css_template.replace(/%s/, BORDER_STYLE[@has_border.toString()])
