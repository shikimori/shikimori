import getjs from 'get-js'
import AdView from './ad_view'

state = null
pending_ads = []

STATE = {
  LOADED: 'loaded'
  LOADING: 'loading'
}

export class MytargetAd extends AdView
  initialize: (@html, @css_class) ->
    if state == STATE.LOADED
      @_render()
    else if state == STATE.LOADING
      @_schedule()
    else if state == null
      @_load_js()

  _load_js: ->
    state = STATE.LOADING

    getjs('//ad.mail.ru/static/ads-async.js').then =>
      state = STATE.LOADED
      pending_ads.forEach (render) -> render()
      @_render()

  _schedule: ->
    pending_ads.push @_render

  _render: =>
    @_replace_node()
    (window.MRGtag = window.MRGtag || []).push({})
