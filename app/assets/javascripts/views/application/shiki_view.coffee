# общий класс для комментария, топика, редактора
module.exports = class ShikiView extends View
  MAX_PREVIEW_HEIGHT: 450
  COLLAPSED_HEIGHT: 150

  _initialize: ->
    super

    @$node.removeClass 'unprocessed'
    @$inner = @$('>.inner')

    return unless @$inner.exists()

  _check_height: =>
    if SHIKI_USER.is_comments_auto_collapsed
      @$inner.check_height
        max_height: @MAX_PREVIEW_HEIGHT
        collapsed_height: @COLLAPSED_HEIGHT

  _shade: =>
    @$node.addClass 'b-ajax'

  _unshade: =>
    @$node.removeClass 'b-ajax'

  _reload: =>
    @_shade()
    $.getJSON @_reload_url(), (response) =>
      @_replace response.content, response.JS_EXPORTS

  # урл для перезагрузки элемента
  _reload_url: ->
    @$node.data 'url'

  _replace: (html, JS_EXPORTS) ->
    $replaced = $(html)
    @$node.replaceWith $replaced

    $replaced.process(JS_EXPORTS).yellow_fade()
