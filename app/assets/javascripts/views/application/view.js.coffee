# общий класс для любого вью объекта
class @View
  constructor: (node) ->
    @_initialize node
    @initialize @$node
    @_after_initialize()

  on: ->
    @$node.on.apply(@$node, arguments)

  trigger: ->
    @$node.trigger.apply(@$node, arguments)

  $: (selector) ->
    $(selector, @$node)

  html: (html) ->
    @$node.html html

  # внутренняя инициализация
  _initialize: (node) ->
    @$node = @$root = $(node)
    @node = @root = @$node[0]

    @$node.view(@)

  # колбек после инициализации
  _after_initialize: ->
