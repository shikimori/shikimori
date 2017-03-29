#= require './topic'

using 'DynamicElements'
class DynamicElements.Dialog extends DynamicElements.Topic
  initialize: ->
    @_check_height()
    @on 'appear', @_appear

    # по клику на Ответить помечаем сущность прочитанной
    @$('.item-reply').on 'click', (e) =>
      @$('.b-new_marker.active').click()
      true

  _check_height: ->
    @$inner.check_height
      max_height: @MAX_PREVIEW_HEIGHT
      collapsed_height: @COLLAPSED_HEIGHT

  _type: -> 'dialog'
  _type_label: -> I18n.t('frontend.dynamic_elements.dialog.type_label')
