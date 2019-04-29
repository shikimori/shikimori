import View from 'views/application/view'

export default class PageBorder extends View
  REGEXP = /\/\* AUTO=page_border \*\/ \.l-page\b.*[\r\n]?/

  initialize: ->
    @css_template = @$root.data 'css_template'
    @$input = @$('input')
    @input = @$input[0]

    @$input.on 'change', @_sync_state

  update: (css) ->
    @has_border = @_extract(css)
    @input.checked = @has_border

  _extract: (css) ->
    !!css.match(REGEXP)

  _sync_state: =>
    @has_border = @input.checked
    @trigger 'component:update', [REGEXP, @_compile()]

  _compile: ->
    if @has_border
      @css_template
    else
      ''
