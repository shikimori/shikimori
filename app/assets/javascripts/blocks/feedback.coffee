import ShikiModal from 'views/application/shiki_modal'
import flash from 'services/flash'

$(document).on 'page:load', ->
  $feedback = $('.b-feedback')

  $('.marker-positioner', $feedback).on 'ajax:success', (e, data) ->
    $form = $(data)
    $form.find('.b-shiki_editor.unprocessed').shikiEditor()
    modal = new ShikiModal $form

    $form.on 'ajax:success', ->
      flash.notice I18n.t('frontend.blocks.feedback.message_sent')
      modal.close()
