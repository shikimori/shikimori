import AdView from './ad_view'

state = null
pending_ads = []

class YandexAd extends AdView
  STATE = {
    LOADED: 'loaded'
    LOADING: 'loading'
  }

  initialize: (@html, @css_class, @ad_params) ->
    if state == STATE.LOADED
      @_render()
    else if state == STATE.LOADING
      @_schedule()
    else
      @_load_js()

  _load_js: ->
    state = STATE.LOADING
    @_schedule()

    ((w, d, n) =>
      w[n] = w[n] || []
      w[n].push ->
        state = STATE.LOADED
        pending_ads.forEach (render) -> render()
        pending_ads = []

      t = d.getElementsByTagName('script')[0]
      s = d.createElement('script')
      s.type = 'text/javascript'
      s.src = '//an.yandex.ru/system/context.js'
      s.async = true
      s.onerror = =>
        if 'remove_ad' of window
          window.remove_ad @css_class
      t.parentNode.insertBefore(s, t)
    )(window, window.document, 'yandexContextAsyncCallbacks')

  _schedule: ->
    pending_ads.push @_render

  _render: =>
    @_replace_node()
    Ya.Context.AdvManager.render @ad_params
