@on 'page:load', 'anime_videos_new', 'anime_videos_edit', 'anime_videos_create', 'anime_videos_update', ->
  once_submit $('form')

  $video_url = $('#anime_video_url')
  $episode = $('#anime_video_episode')
  $video_preview = $('.video-preview')

  if $video_preview.data('player_html')
    preview_video $video_preview.data('player_html')

  if $episode.val() == ''
    $episode.focus()
  else
    $video_url.focus()

  # клик по "Проверить видео"
  $('.do-preview').on 'click', ->
    $('.video-preview').removeClass('hidden')

    $.ajax
      url: $(@).data 'href'
      data:
        url: $('#anime_video_url').val()
      type: 'POST'
      dataType: 'json'
      success: (data, status, xhr) ->
        preview_video data.player_html

  # клик по "Работает и загрузить ещё"
  $('.continue').on 'click', ->
    $('#continue').val('true')

preview_video = (player_html) ->
  $('.video-preview')
    .show()
    .html(player_html)
  $('.create-buttons').show()

once_submit = ($form) ->
  $form.on 'submit', ->
    if $form.data('blocked')
      false
    else
      $form.data blocked: true
