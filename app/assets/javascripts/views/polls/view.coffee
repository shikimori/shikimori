using 'Polls'
module.exports = class Polls.View extends View
  TEMPLATE = 'polls/poll'

  initialize: (@model) ->
    @_render()

  _render: ->
    $old_root = @$root
    @_set_root JST[TEMPLATE](model: @model)
    $old_root.replaceWith @$root
