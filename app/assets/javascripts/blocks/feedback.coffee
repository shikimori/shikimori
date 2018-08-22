import ShikiModal from 'views/application/shiki_modal'

$(document).on 'page:load', ->
  $feedback = $('.b-feedback')

  $('.marker-positioner', $feedback).on 'ajax:success', (e, data) ->
    $form = $(data)
    $form.find('.b-shiki_ditor.unprocessed').shikiEditor()
    modal = new ShikiModal $form

    $form.on 'ajax:success', ->
      $.notice I18n.t('frontend.blocks.feedback.message_sent')
      modal.close()
