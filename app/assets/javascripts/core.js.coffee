#= require core/jquery-2.1.1
#= require core/jquery-migrate-1.2.1
#= require_tree ./core

#= require_tree ./vendor
#= require ./lib/shiki_view
#= require ./lib/shiki_editable
#= require_tree ./lib
#= require_tree ./blocks

#= require turbolinks

bindings = {
  'page:load': [],
  'page:restore': []
}

@mobile_detect = new MobileDetect(window.navigator.userAgent)

@on = (event, conditions..., callback) ->
  bindings[event].push
    conditions: conditions
    callback: callback

# на мобильной ли мы версии (телефон)
@is_mobile = ->
  !!@mobile_detect.mobile() || screen.width <= 480

# на мобильной ли мы версии (планшет или ниже)
@is_tablet = ->
  !!@mobile_detect.tablet() || screen.width <= 768

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
