#= require_tree ./core

#= require_tree ./vendor
#= require_tree ./lib
#= require_tree ./blocks

#= require turbolinks

bindings = {
  'page:load': [],
  'page:restore': []
}

@on = (event, conditions..., callback) ->
  bindings[event].push
    conditions: conditions
    callback: callback

$(document).on 'page:load page:restore', (e) ->
  for group in bindings[e.type]
    if !group.conditions.length || group.conditions.any((v) -> document.body.id == v)
      group.callback()
