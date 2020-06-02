import cookies from 'js-cookie'
import delay from 'delay'

import View from 'views/application/view'

remove_ad = (ad_class) ->
  console.log "remove ad #{ad_class}"
  $(".#{ad_class}").remove()

ad_state = null

export class AdView extends View
  AD_STATE = {
    LOADED: 'loaded'
  }

  CLOSE_AD_HTML = "<div class='close-ad'></div>"

  initialize: (@html, @css_class, @ad_params) ->
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

    if cookies.get("#{@css_class}_disabled")
      @$node.remove()
    else
      $ad = $("<div>#{@html}</div>")
        .addClass(@css_class)
        .append($close)

      @$node.replaceWith $ad

      $close.on 'click', =>
        cookies.set("#{@css_class}_disabled", '1', expires: 7)
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
