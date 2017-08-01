autosize = require 'autosize'

using 'Styles'
class Styles.Edit extends View
  SPECIAL_KEYS = [
    37,38,39,40, # arrows
    91, # cmd
    18, # alt
    17, # ctrl
    16, # shift
    13 # enter,
    9 # tab
  ]

  initialize: ->
    @md5 = require('blueimp-md5')
    @$form = @$ '.edit_style'
    @$css = @$ '#style_css'
    @$preview = @$ '.preview'

    @css_cache = {}

    @components = [
      new Styles.PageBackgroundColor(@$('.page_background_color')),
      new Styles.PageBorder(@$('.page_border'))
      new Styles.BodyBackground(@$('.body_background'))
    ]

    @_debounced_preview = debounce(500, @preview)
    @_debounced_sync = debounce(500, @sync)

    @_sync_components()

    @$form
      .on 'ajax:before', => @$form.find('.editor-container').addClass 'b-ajax'
      .on 'ajax:complete', => @$form.find('.editor-container').removeClass 'b-ajax'

    @$css
      .on 'keypress keydown', @_input_keypress
      .on 'cut paste', @_debounced_sync
      .on 'keydown', (e) =>
        @_debounced_sync() unless SPECIAL_KEYS.includes? e.keyCode
      .one 'focus', =>
        delay().then => autosize @$css[0]
    @$root
      .on 'component:update', @_component_updated

  preview: =>
    css = @$css.val().trim()
    hash = @md5(css)

    if @css_cache[hash]
      @_replace_custom_css(@css_cache[hash])
    else
      @$preview.show()
      @_fetch_preview css, hash

  sync: =>
    @preview()
    @_sync_components()

  _input_keypress: (e) =>
    if (e.metaKey || e.ctrlKey) && (e.keyCode == 10 || e.keyCode == 13)
      # save on ctrl+enter
      @$form.submit()

  _sync_components: ->
    css = @$css.val()

    @components.forEach (component) ->
      component.update css
      true

  _component_updated: (e, regexp, replacement) =>
    css = @$css.val()

    fixed_replacement = if replacement then replacement + "\n" else ''
    if css.match(regexp)
      @$css.val css.replace(regexp, fixed_replacement).trim()
    else if replacement
      @$css.val (fixed_replacement + css).trim()

    @$css.trigger 'autosize:update'

    @_debounced_preview()

  _fetch_preview: (css, hash) ->
    $.post(@$preview.data('url'), style: { css: css })
      .success (style) =>
        @css_cache[hash] = style.compiled_css
        @_replace_custom_css style.compiled_css
      .done =>
        @$preview.hide()

  _replace_custom_css: (compiled_css) ->
    custom_css_id = @$root.data 'custom_css_id'
    $("##{custom_css_id}").html compiled_css
