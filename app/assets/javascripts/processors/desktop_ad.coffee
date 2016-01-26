class @DesktopAd extends View
  initialize: ->
    return if is_mobile() || is_tablet()

    $new_content = $(@$node.data('html'))
    $iframe = $new_content.find 'iframe'

    $iframe.on 'load', ->
      iframe = $iframe[0]
      doc = if iframe.contentDocument
        iframe.contentDocument
      else
        iframe.contentWindow.document

      doc.no_ads = ->
        unless $('iframe,#placeholder', doc).exists()
          $new_content.remove()

      doc.no_ads.delay(3.5 * 1000)

    @$node.replaceWith $new_content
