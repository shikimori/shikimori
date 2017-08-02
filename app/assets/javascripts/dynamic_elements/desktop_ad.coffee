remove_ad = (ad_class) ->
  console.log "remove ad #{ad_class}"
  $(".#{ad_class}").remove()

advertur_state = null

yandex_direct_state = null
yandex_direct_pending_ads = []

ADVERTUR_STATE = {
  LODED: 'loaded'
}

YANDEX_DIRECT_STATE = {
  LOADED: 'loaded'
  LOADING: 'loading'
}

using 'DynamicElements'
class DynamicElements.DesktopAd extends View
  initialize: ->
    return if is_mobile() && !mobile_detect.tablet()

    @provider = @$node.data 'ad_provider'
    @html = @$node.data 'ad_html'
    @css_class = @$node.data 'ad_css_class'
    @ad_params = @$node.data 'ad_params'

    if @provider == 'yandex_direct'
      @_yandex_direct()
    else
      @_advertur()

  _yandex_direct: ->
    if yandex_direct_state == YANDEX_DIRECT_STATE.LOADED
      @_render_yandex_ad()
    else if yandex_direct_state == YANDEX_DIRECT_STATE.LOADING
      @_schedule_yandex_ad()
    else
      @_load_yandex_js()

  _load_yandex_js: ->
    yandex_direct_state = YANDEX_DIRECT_STATE.LOADING
    @_schedule_yandex_ad()

    ((w, d, n) =>
      w[n] = w[n] || [];
      w[n].push =>
        yandex_direct_state = YANDEX_DIRECT_STATE.LOADED
        yandex_direct_pending_ads.forEach (render) -> render()
        yandex_direct_pending_ads = []

      t = d.getElementsByTagName("script")[0];
      s = d.createElement("script");
      s.type = "text/javascript";
      s.src = "//an.yandex.ru/system/context.js";
      s.async = true;
      s.onerror = => window.remove_ad @css_class
      t.parentNode.insertBefore(s, t);
    )(window, window.document, 'yandexContextAsyncCallbacks');

  _schedule_yandex_ad: ->
    yandex_direct_pending_ads.push @_render_yandex_ad

  _render_yandex_ad: =>
    @_replace_node()
    Ya.Context.AdvManager.render @ad_params

  _advertur: ->
    if advertur_state != ADVERTUR_STATE.LOADED
      @_load_advertur_handler()

    @_replace_node()

  _load_advertur_handler: ->
    advertur_state = ADVERTUR_STATE.LOADED
    $(window).on 'message', (e) ->
      if e.originalEvent.data?.type == 'remove_ad'
        remove_ad(e.originalEvent.data.ad_class)

  _replace_node: ->
    @$node.replaceWith $(@html).addClass(@css_class)

    # $new_content = $(@html).addClass(@css_class)

    # $iframe = $new_content.find 'iframe'
    # console.log $new_content.html()

    # $iframe.on 'load', ->
      # iframe = $iframe[0]
      # doc = if iframe.contentDocument
        # iframe.contentDocument
      # else
        # iframe.contentWindow.document

      # delay(3.5 * 1000).then ->
        # unless $('iframe,#placeholder', doc).exists()
          # $new_content.remove()
