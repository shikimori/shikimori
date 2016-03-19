# общий класс для комментария, топика, редактора
class @ShikiView extends View
  MAX_PREVIEW_HEIGHT: 450
  COLLAPSED_HEIGHT: 150

  # внутренняя инициализация
  _initialize: ($node) ->
    super $node

    @$node.removeClass 'unprocessed'
    @$inner = @$('>.inner')

    return unless @$inner.exists()

  # проверка высоты комментария. урезание, если текст слишком длинный (точно такой же код в shiki_topic)
  _check_height: =>
    if OPTIONS.comments_auto_collapsed
      @$inner.check_height @MAX_PREVIEW_HEIGHT, false, @COLLAPSED_HEIGHT

  # тень аякс запроса
  _shade: =>
    @$node.addClass 'ajax_request'

  # убирание тени
  _unshade: =>
    @$node.removeClass 'ajax_request'

  # перезагрузка содержимого
  _reload: =>
    @_shade()
    $.get @_reload_url(), (response) =>
      @_replace response

  # урл для перезагрузки элемента
  _reload_url: ->
    @$node.data 'url'

  # замена элемента контентом
  _replace: (html) ->
    $replaced = $(html)
    @$node.replaceWith $replaced

    $replaced
      .process()
      .yellowFade()
