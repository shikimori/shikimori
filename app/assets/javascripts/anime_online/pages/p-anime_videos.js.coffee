@on 'page:load', 'anime_videos_index', ->
  $('.b-show_more').show_more()

  resize_video_player()

  debounced_resize = $.debounce(250, resize_video_player)
  $(window).on('resize', debounced_resize)
  $(window).one('page:before-unload', -> $(window).off 'resize', debounced_resize)

resize_video_player = ->
  $player = $('.video-player iframe').add $('.video-player embed')
  $player.height($player.width() * 9 / 16)
