jQuery ->
  $page = $('.p-anime_video-show')

  $('.kinds li a', $page).on 'click', ->
    $('.video iframe', $page).attr 'src', $(@).data('url')

  frame = $('iframe', $page)
  frame.height(frame.width() * 9 / 16)
  console.log frame.width()
