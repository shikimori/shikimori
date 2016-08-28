# общий класс для комментария, топика, редактора
class @ShikiView extends View
  MAX_PREVIEW_HEIGHT: 450
  COLLAPSED_HEIGHT: 150

  # внутренняя инициализация
  _initialize: ->
    super

    @$node.removeClass 'unprocessed'
    @$inner = @$('>.inner')

    return unless @$inner.exists()

  # проверка высоты комментария. урезание, если текст слишком длинный (точно такой же код в shiki_topic)
  _check_height: =>
    if OPTIONS.comments_auto_collapsed
      @$inner.check_height
        max_height: @MAX_PREVIEW_HEIGHT
        collapsed_height: @COLLAPSED_HEIGHT

  # тень аякс запроса
  _shade: =>
    @$node.addClass 'b-ajax'

  # убирание тени
  _unshade: =>
    @$node.removeClass 'b-ajax'

  # перезагрузка содержимого
  _reload: =>
    @_shade()
    $.getJSON @_reload_url(), (response) =>
      @_replace response.content, response.JS_EXPORTS

  # урл для перезагрузки элемента
  _reload_url: ->
    @$node.data 'url'

  # замена элемента контентом
  _replace: (html, JS_EXPORTS) ->
    $replaced = $(html)
    @$node.replaceWith $replaced

    $replaced.process(JS_EXPORTS).yellowFade()
