#= require jquery
#= require core/jquery-migrate-1.2.1
#= require_tree ./core

#= require eventie
#= require eventEmitter
#= require magnific-popup

# dependencies for packery
#= require jquery-bridget
#= require matches-selector
#= require doc-ready
#= require classie
#= require get-style-property
#= require get-size
#= require outlayer
#= require packery

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

$.bridget 'packery', Packery

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
    body_classes = if group.conditions.length && group.conditions[0][0] == '.'
      group.conditions
        .filter (v) -> v[0] == '.'
        .map (v) -> "p-#{v.slice 1}-"
    else
      null

    if !group.conditions.length
      group.callback()
    else if body_classes && body_classes.length && body_classes.any((v) -> document.body.className.indexOf(v) != -1)
      group.callback()
    else if group.conditions.any((v) -> document.body.id == v)
      group.callback()
