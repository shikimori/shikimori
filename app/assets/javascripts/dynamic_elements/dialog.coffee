using 'DynamicElements'
class DynamicElements.Dialog extends ShikiEditable
  initialize: ->
    @_check_height()

    # прочтение комментриев
    @$('.b-new_marker.active').on 'click', (e) =>
      $markers = $(e.target)
      ids = [@$root.data('message_id')]

      $.ajax
        url: @$root.data('appear_url')
        type: 'POST'
        data:
          ids: ids.join ","

      $markers.removeClass 'active'
      $markers.css.bind($markers).delay(1, opacity: 0)
      $markers.hide.bind($markers).delay(500)

    # по клику на Ответить помечаем сущность прочитанной
    @$('.item-reply').on 'click', (e) =>
      @$('.b-new_marker.active').click()
      true

  _type: -> 'dialog'
  _type_label: -> 'Диалог'
