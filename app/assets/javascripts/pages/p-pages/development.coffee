pageLoad 'pages_development', ->
  $ajax = $ '.b-ajax'
  $iframe = $ 'iframe'

  height = $(window).height() - $ajax.offset().top - 5

  $ajax.css width: '100%', height: height - 10
  $iframe.prop width: '100%', height: height

  $iframe.on 'load', ->
    $ajax.hide()
    $iframe.removeClass 'hidden'
