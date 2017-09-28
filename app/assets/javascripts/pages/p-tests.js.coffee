page_load '.tests', ->
  set_link = ->
    $('#link').val location.href.replace(/\?.*/, '') +
      '?image_url=' + $('#image_url').val() +
      '&image_border=' + $('#image_border').val().replace('#', '@')

  $('#image_url')
    .on 'keypress', (e) ->
      if e.keyCode is 10 || e.keyCode is 13
        $(@).trigger 'change'

    .on 'blur change', ->
      $('.b-achievement .c-image img').attr src: @value
      set_link()

    .on 'paste', (e) ->
      delay().then => $(@).trigger 'change'

    .trigger('change')

  $('#image_border')
    .on 'keyup blur change', (e) ->
      $('.b-achievement .c-image .border').css(borderColor: @value)
      set_link()

    .on 'paste', (e) ->
      delay().then => $(@).trigger 'change'

    .trigger('change')
