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

require 'jquery-bridget'
require 'magnific-popup'
require 'imagesLoaded'
require 'packery'

#= require d3
#= require nouislider

# imagesLoaded dependency
#= require ev-emitter

# magnific-popup dependency
#= require magnific-popup

#= require_self
