#= require_tree ./core

#= require_tree ./vendor
#= require ./lib/shiki_view
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
    body_class = if group.conditions.length && group.conditions[0][0] == '.'
      "p-#{group.conditions[0].slice 1}-"
    else
      null

    if !group.conditions.length
      group.callback()
    else if body_class && document.body.className.indexOf(body_class) != -1
      group.callback()
    else if group.conditions.any((v) -> document.body.id == v)
      group.callback()
