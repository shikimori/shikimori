# общий класс для комментария, топика, редактора
class @ShikiView
  MAX_PREVIEW_HEIGHT: 200

  constructor: ($root) ->
    @_initialize($root)
    @initialize(@$root)

  on: ->
    @$root.on.apply(@$root, arguments)

  trigger: ->
    @$root.trigger.apply(@$root, arguments)

  $: (selector) ->
    $(selector, @$root)

  # внутренняя инициализация
  _initialize: ($root) ->
    @$root = $root
    @$root.removeClass('unprocessed')
    @$inner = @$('>.inner')
    return unless @$inner.exists()

    # cancel control in mobile expanded aside
    $('.item-cancel', @$inner).on 'click', =>
      @_close_aside()

    # deletion
    $('.item-delete', @$inner).on 'click', =>
      $('.main-controls', @$inner).hide()
      $('.delete-controls', @$inner).show()

    # confirm deletion
    $('.item-delete-confirm', @$inner).on 'ajax:loading', (e, data, status, xhr) =>
      $.hideCursorMessage()
      @$root
        .animated_collapse()
        .remove.bind(@$root).delay(500)

    # cancel deletion
    $('.item-delete-cancel', @$inner).on 'click', =>
      #@$('.main-controls').show()
      #@$('.delete-controls').hide()
      @_close_aside()

    # переключение на мобильую версию кнопок кнопок
    $('.item-mobile', @$inner).on 'click', =>
      @$root.toggleClass('aside-expanded')
      $('.item-mobile', @$inner).toggleClass('selected')
      # из-за снятия overflow для элемента с .aside-expanded, сокращённая высота работает некорректно, поэтому её надо убрать
      @$root.find('>.b-height_shortener').click()

  # закрытие кнопок в мобильной версии
  _close_aside: ->
    $('.item-mobile', @$inner).click() if $('.item-mobile', @$inner).is('.selected')

    $('.main-controls', @$inner).show()
    $('.delete-controls', @$inner).hide()
    $('.moderation-controls', @$inner).hide()

  # проверка высоты комментария. урезание, если текст слишком длинный (точно такой же код в shiki_topic)
  _check_height: =>
    @$inner.check_height(@MAX_PREVIEW_HEIGHT)
