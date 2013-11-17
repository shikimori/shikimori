jQuery ->
  $page = $('.p-anime_video_show')

  $('#kinds li a', $page).on 'click', ->
    $('.video iframe', $page).attr 'src', $(@).data('url')
