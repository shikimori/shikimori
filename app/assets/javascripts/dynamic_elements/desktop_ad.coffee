using 'DynamicElements'
class DynamicElements.DesktopAd extends View
  initialize: ->
    provider = @$node.data 'ad_provider'
    html = @$node.data 'ad_html'
    css_class = @$node.data 'ad_css_class'
    ad_params = @$node.data 'ad_params'
    platform = @$node.data 'platform'

    return unless @_platform_matches(platform)

    if provider == 'yandex_direct'
      new Ads.Yandex(@$node, css_class, ad_params)
    else if provider == 'mytarget'
      new Ads.Mytarget(@$node, html, css_class, ad_params)
    else
      new Ads.View(@$node, html, css_class, ad_params)

  _platform_matches: (platform) ->
    if platform == 'desktop'
      is_mobile() && !mobile_detect.tablet()
    else
      mobile_detect.phone() || mobile_detect.tablet()
