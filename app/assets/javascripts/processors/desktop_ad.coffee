# function is called from ad iframe
@remove_ad = (ad_class) ->
  console.log "remove ad #{ad_class}"
  $(".#{ad_class}").remove()

class @DesktopAd extends View
  initialize: ->
    return if is_mobile() || is_tablet()

    $new_content = $(@$node.data('html'))
    $new_content.addClass @$node.data('ad_class')
    # $iframe = $new_content.find 'iframe'
    # console.log $new_content.html()

    # $iframe.on 'load', ->
      # iframe = $iframe[0]
      # doc = if iframe.contentDocument
        # iframe.contentDocument
      # else
        # iframe.contentWindow.document

      # (->
        # unless $('iframe,#placeholder', doc).exists()
          # $new_content.remove()
      # ).delay 3.5 * 1000

    @$node.replaceWith $new_content
