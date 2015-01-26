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

  $('.create-user_rate').on 'ajax:success', ->
    $link = $(@)

    $.notice 'Аниме добавлено в список'
    $link
      .removeClass('create-user_rate')
      .addClass('increment-user_rate')
      .attr
        href: $link.data('increment_url')

    $link.find('.label').text('просмотрено')

  $('.increment-user_rate').on 'ajax:success', ->
    unless $('.increment-user_rate').hasClass('watched')
      $.notice 'Эпизод отмечен просмотренным'
    (-> Turbolinks.visit $('.c-control.next').attr('href')).delay 500

resize_video_player = ->
  $player = $('iframe,object,embed,.placeholder', '.video-player')
  $player.height($player.width() * 9 / 16)
