# общий класс для любого вью объекта
export default class View
  constructor: (node, arg1, arg2, arg3) ->
    @_initialize node
    @initialize arg1, arg2, arg3
    @_after_initialize()

  on: ->
    @$node.on.apply(@$node, arguments)
    @

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

  # set root node
  _set_root: (node) ->
    @$root = @$node = $(node)
    @root = @node = @$root[0]
    @$root.data view_object: @
