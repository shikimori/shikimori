getjs = require('get-js')
require 'views/ads/view'

state = null

using 'Ads'
class Ads.Mytarget extends Ads.View
  STATE = {
    LOADED: 'loaded'
    LOADING: 'loading'
  }

  initialize: (@html, @css_class) ->
    if state == STATE.LOADED
      @_render()
    else if state == null
      @_load_js()

  _load_js: ->
    state = STATE.LOADING

    getjs('//ad.mail.ru/static/ads-async.js').then =>
      state = STATE.LOADED
      @_render()

  _render: ->
    @_replace_node()
    (window.MRGtag = window.MRGtag || []).push({})
