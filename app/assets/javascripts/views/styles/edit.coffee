using 'Styles'
class Styles.Edit extends View
  DEBOUNCE_INTERVAL = 100

  initialize: ->
    @$form = @$ '.edit_style'
    @$css = @$ '#style_css'

    new Styles.BodyOpacity @$('.body_opacity'), @$css

    @$css.elastic()
    @$form
      .on 'ajax:before', => @$css.parent().addClass 'b-ajax'
      .on 'ajax:complete', => @$css.parent().removeClass 'b-ajax'

    @$css
      .on 'keypress keydown', @_input_keypress
      .on 'keypress keydown', => @_preview.debounce(DEBOUNCE_INTERVAL)
    @$root
      .on 'component:update', => @_preview.debounce(DEBOUNCE_INTERVAL)

  _input_keypress: (e) =>
    if (e.metaKey || e.ctrlKey) && (e.keyCode == 10 || e.keyCode == 13)
      # сохранение по ctrl+enter
      @$form.submit()

  _preview: ->
    console.log 'preview'
