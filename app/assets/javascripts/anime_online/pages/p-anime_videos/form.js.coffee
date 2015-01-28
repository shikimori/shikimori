@on 'page:load', 'anime_videos_new', 'anime_videos_edit', ->
  $('.do-preview').on 'click', ->
    $('.video-preview').show()

    $.getJSON "#{$(@).data 'href'}?url=#{encodeURIComponent $('#anime_video_url').val()}", (data) ->
      $('.video-preview iframe').attr src: data.url
      $('.b-form input[type=submit]').show()
