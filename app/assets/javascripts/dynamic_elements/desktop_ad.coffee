remove_ad = (ad_class) ->
  console.log "remove ad #{ad_class}"
  $(".#{ad_class}").remove()

ad_state = null

yandex_direct_state = null
yandex_direct_pending_ads = []

using 'DynamicElements'
class DynamicElements.DesktopAd extends View
  CLOSE_AD_HTML = "<div class='close-ad'></div>"

  AD_STATE = {
    LOADED: 'loaded'
  }

  YANDEX_DIRECT_STATE = {
    LOADED: 'loaded'
    LOADING: 'loading'
  }

  initialize: ->
    return if is_mobile() && !mobile_detect.tablet()

    @provider = @$node.data 'ad_provider'
    @html = @$node.data 'ad_html'
    @css_class = @$node.data 'ad_css_class'
    @ad_params = @$node.data 'ad_params'

    if @provider == 'yandex_direct'
      @_yandex_direct()
    else
      @_other_ad()

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
      s.onerror = =>
        if 'remove_ad' of window
          window.remove_ad @css_class
      t.parentNode.insertBefore(s, t);
    )(window, window.document, 'yandexContextAsyncCallbacks');

  _schedule_yandex_ad: ->
    yandex_direct_pending_ads.push @_render_yandex_ad

  _render_yandex_ad: =>
    @_replace_node()
    Ya.Context.AdvManager.render @ad_params

  _other_ad: ->
    if ad_state != AD_STATE.LOADED
      @_load_ad_handler()

    @_replace_node()

  _load_ad_handler: ->
    ad_state = AD_STATE.LOADED
    $(window).on 'message', (e) ->
      if e.originalEvent.data?.type == 'remove_ad'
        remove_ad(e.originalEvent.data.ad_class)

  _replace_node: ->
    $close = $(CLOSE_AD_HTML)

    if $.cookie("#{@css_class}_disabled")
      @$node.remove()
    else
      $ad = $("<div>#{@html}</div>")
        .addClass(@css_class)
        .append($close)

      @$node.replaceWith $ad

      $close.on 'click', =>
        $.cookie("#{@css_class}_disabled", '1', expires: 7)
        $close.remove()
        $ad.addClass 'removing'
        delay(1000).then =>
          remove_ad @css_class

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
