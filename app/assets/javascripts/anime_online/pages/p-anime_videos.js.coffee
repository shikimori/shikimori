@on 'page:load', 'anime_videos_index', ->
  resize_player()
  $(window).resize resize_player

resize_player = ->
  $frame = $('.video-player iframe')
  $frame.height($frame.width() * 9 / 16) if $frame

  $object = $('.video-player object')
  if $object
    width = $object.parent().width()
    $object.width(width).height(width * 9 / 16)
    $('embed', $object).width(width).height(width * 9 / 16)

