using 'Styles'
class Styles.Edit extends View
  initialize: ->
    @$form = @$ '.edit_style'
    @$css = @$ '#style_css'
    @$preview = @$ '.preview'

    new Styles.PageBackgroundColor @$('.page_background_color'), @$css

    @$css.elastic()

    @debounced_preview = @_preview.debounce(500)

    @$form
      .on 'ajax:before', => @$css.parent().addClass 'b-ajax'
      .on 'ajax:complete', => @$css.parent().removeClass 'b-ajax'

    @$css
      .on 'keypress keydown', @_input_keypress
      .on 'keydown cut paste', @debounced_preview
    @$root
      .on 'component:update', @_component_update

  _input_keypress: (e) =>
    if (e.metaKey || e.ctrlKey) && (e.keyCode == 10 || e.keyCode == 13)
      # сохранение по ctrl+enter
      @$form.submit()

  _preview: =>
    css = @$css.val()
    @preview_cache ||= {}

    if @preview_cache[css]
      @_replace_custom_css(@preview_cache[css]) 
    else
      @$preview.show()
      $.post(@$preview.data('url'), style: { css: css })
        .success (style) =>
          @preview_cache[css] = style.compiled_css
          @_replace_custom_css style.compiled_css
        .done =>
          @$preview.hide()

  _component_update: =>
    @$css.trigger 'elastic:update'
    @debounced_preview()

  _replace_custom_css: (compiled_css) ->
    custom_css_id = @$root.data 'custom_css_id'
    $("##{custom_css_id}").html compiled_css
