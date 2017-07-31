# function is called from ad iframe
@remove_ad = (ad_class) ->
  console.log "remove ad #{ad_class}"
  $(".#{ad_class}").remove()

yandex_direct_state = null
yandex_direct_pending_ads = []

LOADED = 'loaded'
LOADING = 'loading'

using 'DynamicElements'
class DynamicElements.DesktopAd extends View
  initialize: ->
    return if is_mobile() && !mobile_detect.tablet()

    @type = @$node.data 'ad_type'
    @html = @$node.data 'ad_html'
    @css_class = @$node.data 'ad_css_class'
    @ad_params = @$node.data 'ad_params'

    if @type == 'yandex_direct'
      @yandex_direct()
    else
      @advertur()

  yandex_direct: ->
    if yandex_direct_state == LOADED
      @render_yandex_ad()
    else if yandex_direct_state == LOADING
      @schedule_yandex_ad()
    else
      @load_yandex_js()

  load_yandex_js: ->
    yandex_direct_state = LOADING
    @schedule_yandex_ad()

    ((w, d, n, s, t) =>
      w[n] = w[n] || [];
      w[n].push =>
        yandex_direct_state = LOADED
        yandex_direct_pending_ads.forEach (render) -> render()
        yandex_direct_pending_ads = []

      t = d.getElementsByTagName("script")[0];
      s = d.createElement("script");
      s.type = "text/javascript";
      s.src = "//an.yandex.ru/system/context.js";
      s.async = true;
      t.parentNode.insertBefore(s, t);
    )(window, window.document, 'yandexContextAsyncCallbacks');

  schedule_yandex_ad: ->
    yandex_direct_pending_ads.push @render_yandex_ad

  render_yandex_ad: =>
    @replace_node()
    Ya.Context.AdvManager.render @ad_params

  advertur: ->
    @replace_node()

  replace_node: ->
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
