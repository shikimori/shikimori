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
    @$form = @$ '.edit_style'
    @$css = @$ '#style_css'
    @$preview = @$ '.preview'

    @css_cache = {}

    @components = [
      new Styles.PageBackgroundColor(@$('.page_background_color')),
      new Styles.PageBorder(@$('.page_border'))
      new Styles.BodyBackground(@$('.body_background'))
    ]

    @_debounced_preview = @preview.debounce(500)
    @_debounced_sync = @sync.debounce(500)

    @$css.elastic()
    @_sync_components()

    @$form
      .on 'ajax:before', => @$css.parent().addClass 'b-ajax'
      .on 'ajax:complete', => @$css.parent().removeClass 'b-ajax'

    @$css
      .on 'keypress keydown', @_input_keypress
      .on 'cut paste', @_debounced_sync
      .on 'keydown', (e) =>
        @_debounced_sync() unless SPECIAL_KEYS.includes? e.keyCode
    @$root
      .on 'component:update', @_component_updated

  preview: =>
    css = @$css.val().trim()
    hash = md5(css)

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

    @components.each (component) ->
      component.update css
      true

  _component_updated: (e, regexp, replacement) =>
    css = @$css.val()

    if css.match(regexp)
      @$css.val css.replace(regexp, replacement)
    else if replacement
      @$css.val replacement + "\n\n" + css.trim()

    @$css.trigger 'elastic:update'
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
