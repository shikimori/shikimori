# import Vue from 'vue/dist/vue.esm'

# require 'pikaday'
# require 'urijs'

window.Sugar = require 'sugar'
Sugar.extend()

window.$ = window.jQuery = require 'jquery'
window.moment = require 'moment'
window.I18n = require 'i18n-js'
window.Turbolinks = require 'turbolinks'

require '../i18n/translations'

require_vendor = require.context('../vendor', true)
require_vendor.keys().forEach(require_vendor)

require 'magnific-popup'
require 'imagesLoaded'

#= require uevent
#= require d3
#= require nouislider

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

#= require jade/runtime

#= require_self

bindings = require('helpers/bindings')

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
