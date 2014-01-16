jQuery ->
  $page = $('.p-anime_video-new')

  $('.check', $page).on 'click', ->
    $('iframe', $page).removeClass('hidden').attr 'src', $('#anime_video_url').val()
    $('.save', $page).removeClass('hidden')

  if $('#anime_video_url').val() != ''
    $('.save', $page).removeClass('hidden')
