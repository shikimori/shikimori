jQuery ->
  $page = $('.p-anime_video-new')

  $('.check', $page).on 'click', ->
    url = $('#anime_video_url').val()
    $('.load', $page).removeClass 'hidden'
    $.ajax
      url: '/videos/extract_url'
      data:
        url: url
      type: 'POST'
      success: (e) ->
        $('iframe', $page).removeClass('hidden').attr 'src', e
        $('.save', $page).removeClass 'hidden'
        $('.load', $page).addClass 'hidden'

  if $('#anime_video_url').val() != ''
    $('.save', $page).removeClass 'hidden'
