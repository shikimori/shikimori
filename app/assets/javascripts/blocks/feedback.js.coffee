LOCALES = {
  ru: 'Сообщение отправлено',
  en: 'Message sent'
}

$(document).on 'page:load', ->
  $feedback = $('.b-feedback')

  $('.marker-positioner', $feedback).on 'ajax:success', (e, data) ->
    $form = $(data).shiki_modal()

    $form.find('.b-shiki_editor.unprocessed').shiki_editor()

    $form.on 'ajax:success', ->
      $.notice LOCALES[LOCALE]
      $form.view().close()
