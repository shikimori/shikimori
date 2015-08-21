# общий класс для процессоров
class @BaseProcessor
  constructor: (node) ->
    @node = node
    @$node = $(@node)
    @initialize()

  on: ->
    @$node.on.apply(@$node, arguments)

  trigger: ->
    @$node.trigger.apply(@$node, arguments)

  $: (selector) ->
    $(selector, @$node)
