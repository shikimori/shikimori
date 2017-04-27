# import Vue from 'vue/dist/vue.esm'

# require 'urijs'

require('sugar').extend()
require('es6-promise').polyfill()

window.$ = window.jQuery = require 'jquery'
window.moment = require 'moment'
window.I18n = require 'i18n-js'
window.Turbolinks = require 'turbolinks'

require '../i18n/translations'

require_vendor = require.context('../vendor', true)
require_vendor.keys().forEach(require_vendor)

require 'jquery-bridget'

require 'magnific-popup'
require 'magnific-popup/dist/magnific-popup.css'
require 'nouislider/distribute/nouislider.css'
require 'pikaday/scss/pikaday.scss'

require 'imagesLoaded'
require 'packery'

#= require d3
#= require_self
