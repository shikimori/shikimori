LOCALES = {
  ru: 'Сообщение отправлено',
  en: 'Message sent'
}

$(document).on 'page:load', ->
  $feedback = $('.b-feedback')

  $('.marker-positioner', $feedback).on 'ajax:before', (e, data) ->
    $.scrollTo(0)

  $('.marker-positioner', $feedback).on 'ajax:success', (e, data) ->
    $feedback.find('.message').remove()
    $form = $(data).prependTo($feedback)

    $form
      .find('.b-shiki_editor.unprocessed')
      .shiki_editor()

    $form.on 'ajax:success', ->
      $.notice LOCALES[LOCALE]
      $('#shade').trigger 'click'

    $('#shade').show()
    $('#shade').one 'click', ->
      $form.remove()
      $(@).hide()
