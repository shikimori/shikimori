# общий класс для комментария, топика, редактора
class @View
  constructor: (root) ->
    @_initialize(root)
    @initialize(@$node)
    @_after_initialize()

  on: ->
    @$node.on.apply(@$node, arguments)

  trigger: ->
    @$node.trigger.apply(@$node, arguments)

  $: (selector) ->
    $(selector, @$node)

  # внутренняя инициализация
  _initialize: (node) ->
    @$node = @$root = $(node)
    @node = @root = @$node[0]

  # колбек после инициализации
  _after_initialize: ->

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
