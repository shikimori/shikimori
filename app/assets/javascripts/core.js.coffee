#= require sugar
#= require jquery
#= require vendor/jquery-migrate-1.3.0
#= require vendor/modernizr

#= require d3
#= require jQuery-Storage-API
#= require pikaday
#= require urijs

# imagesLoaded dependency
#= require ev-emitter
#= require imagesloaded

# magnific-popup dependency
#= require magnific-popup

# outlayer dependency
#= require desandro-matches-selector
#= require fizzy-ui-utils
#= require get-size
#= require outlayer/item
# packery dependency
#= require outlayer
#= require jquery-bridget
#= require packery/rect
#= require packery/packer
#= require packery/item
#= require packery

#= require i18n
#= require_directory ./i18n
#= require jade/runtime

#= require_tree ./templates

#= require_tree ./vendor

#= require_self

#= require ./views/application/view
#= require ./views/application/shiki_view
#= require ./views/application/shiki_editable
#= require_tree ./views

#= require_tree ./dynamic_elements
#= require_tree ./services
#= require_tree ./lib
#= require_tree ./blocks

#= require turbolinks

#= require_tree ./pages

bindings =
  'page:load': []
  'page:restore': []
  'page:change': []

$.bridget 'packery', Packery

@mobile_detect = new MobileDetect(window.navigator.userAgent)

@on = (event, conditions..., callback) ->
  bindings[event].push
    conditions: conditions
    callback: callback

@using = (names) ->
  scope = window
  names.split('.').forEach (name) ->
    scope[name] ||= {}
    scope = scope[name]

# на мобильной ли мы версии (телефон)
@is_mobile = ->
  !!@mobile_detect.mobile() || screen.width <= 480

# на мобильной ли мы версии (планшет или ниже)
@is_tablet = ->
  !!@mobile_detect.tablet() || screen.width <= 768

$(document).on 'page:load page:change page:restore', (e) ->
  for group in bindings[e.type]
    body_classes = if group.conditions.length && group.conditions[0][0] == '.'
      group.conditions
        .filter (v) -> v[0] == '.'
        .map (v) -> "p-#{v.slice 1} "
    else
      null

    if !group.conditions.length
      group.callback()
    else if body_classes && body_classes.length && body_classes.any((v) -> document.body.className.indexOf(v) != -1)
      group.callback()
    else if group.conditions.any((v) -> document.body.id == v)
      group.callback()
