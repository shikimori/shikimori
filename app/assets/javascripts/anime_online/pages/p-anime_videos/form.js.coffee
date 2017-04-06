@on 'page:load', 'anime_videos_new', 'anime_videos_edit', 'anime_videos_create', 'anime_videos_update', ->
  $form = $('form')
  once_submit $form

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
    video_url = $('#anime_video_url').val()
    return unless video_url

    $form.addClass 'b-ajax'
    $('.video-preview').removeClass('hidden')

    $.ajax
      url: $(@).data 'href'
      data:
        url: video_url
      type: 'POST'
      dataType: 'json'
      success: (data, status, xhr) ->
        $form.removeClass 'b-ajax'
        preview_video data.player_html
      error: ->
        $form.removeClass 'b-ajax'
        preview_video null

  # клик по "Работает и загрузить ещё"
  $('.continue').on 'click', ->
    $('#continue').val('true')

  $('#anime_video_author_name')
    .completable()
    .on 'autocomplete:success autocomplete:text', (e, result) ->
      @value = result.value

preview_video = (player_html) ->
  $('.video-preview')
    .show()
    .html(player_html)
  $('.create-buttons').show()

  $('.create-buttons .b-errors').toggle !player_html
  $('.create-buttons .buttons').toggle !!player_html

once_submit = ($form) ->
  $form.on 'submit', ->
    if $form.data('blocked')
      false
    else
      $form.data blocked: true
