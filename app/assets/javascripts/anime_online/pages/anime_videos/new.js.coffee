jQuery ->
  $page = $('.p-anime_video-new')

  $('.check', $page).on 'click', ->
    url = $('#anime_video_url').val()
    unless /^http:\/\//.test url
      url = 'http://' + url
      $('#anime_video_url').val url

    $('iframe', $page).removeClass('hidden').attr 'src', url
    $('.save', $page).removeClass('hidden')

  if $('#anime_video_url').val() != ''
    $('.save', $page).removeClass('hidden')
