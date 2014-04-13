jQuery ->
  $page = $('.p-anime_video-new')
  $episode = $('#anime_video_episode', $page)
  if $episode.val() == ''
    $episode.focus()
  else
    $('#anime_video_url', $page).focus()

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

  if $('#anime_video_url', $page).val() != ''
    $('.save', $page).removeClass 'hidden'

  $('.continue', $page).on 'click', ->
    $('#continue').val('true')
