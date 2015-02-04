@on 'page:load', 'anime_videos_new', 'anime_videos_edit', 'anime_videos_create', 'anime_videos_update', ->
  $video_url = $('#anime_video_url')
  $episode = $('#anime_video_episode')

  if $video_url.val() != ''
    preview_video $video_url.val()

  if $episode.val() == ''
    $episode.focus()
  else
    $video_url.focus()

  # клик по "Проверить видео"
  $('.do-preview').on 'click', ->
    $('.video-preview').show()

    $.getJSON "#{$(@).data 'href'}?url=#{encodeURIComponent $('#anime_video_url').val()}", (data) ->
      preview_video data.url

  # клик по "Работает и загрузить ещё"
  $('.continue').on 'click', ->
    $('#continue').val('true')

preview_video = (url) ->
  $('.video-preview iframe').attr src: url
  $('.buttons').show()
