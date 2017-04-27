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
