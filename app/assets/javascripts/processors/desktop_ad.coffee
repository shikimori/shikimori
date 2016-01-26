class @DesktopAd extends View
  initialize: ->
    return if is_mobile() || is_tablet()
    console.log is_mobile()
    console.log is_tablet()

    @$node.replaceWith @$node.data('html')
