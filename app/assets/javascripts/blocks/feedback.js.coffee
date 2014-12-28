$(document).on 'page:load', (e, is_dom_content_loaded) ->
  $feedback = $('.b-feedback')

  $('.marker-positioner', $feedback).on 'ajax:success', (e, data) ->
    $feedback.find('.message').remove()
    $form = $(data).prependTo($feedback)

    $form
      .find('.b-shiki_editor.unprocessed')
      .shiki_editor()

    $form.on 'ajax:success', ->
      $.notice 'Сообщение отправлено администрации'
      $('#shade').trigger 'click'

    $('#shade').trigger('show', 0.2)
    $('#shade').one 'click', ->
      $form.remove()
