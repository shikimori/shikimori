@on 'page:load', 'anime_videos_index', ->
  $('.b-show_more').show_more()

  resize_video_player()

  debounced_resize = $.debounce(250, resize_video_player)
  $(window).on('resize', debounced_resize)
  $(window).one('page:before-unload', -> $(window).off 'resize', debounced_resize)

  # показ дополнительных кнопок для видео
  $('.show-options').on 'click', ->
    $(@).toggleClass 'selected'
    $('.cc-navigation').toggle()
    $('.cc-optional_controls').toggle()

resize_video_player = ->
  $player = $('iframe,object,embed,.placeholder', '.video-player')
  $player.height($player.width() * 9 / 16)
