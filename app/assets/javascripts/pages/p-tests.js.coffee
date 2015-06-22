@on 'page:load', '.tests', ->
  set_link = ->
    $('#link').val location.href.replace(/\?.*/, '') +
      '?image_url=' + $('#image_url').val() +
      '&image_border=' + $('#image_border').val().replace('#', '@')

  $('#image_url')
    .on 'keypress', (e) ->
      if e.keyCode is 10 || e.keyCode is 13
        $(@).trigger 'change'

    .on 'blur change', ->
      $('.b-achievement .image img').attr src: @value
      set_link()

    .on 'paste', (e) ->
      (=> $(@).trigger 'change').delay()

    .trigger('change')

  $('#image_border')
    .on 'keyup blur change', (e) ->
      $('.b-achievement .image .border').css(borderColor: @value)
      set_link()

    .on 'paste', (e) ->
      (=> $(@).trigger 'change').delay()

    .trigger('change')
