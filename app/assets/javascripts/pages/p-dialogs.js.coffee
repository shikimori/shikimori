@on 'page:load', 'dialogs_index', 'dialogs_show', ->
  $('.b-dialog.unprocessed').shiki_dialog()
  $('.b-message.unprocessed').shiki_message()

  $('textarea:appeared').focus()

  $('.l-page').on 'postloader:success', '.b-postloader', ->
    $('.b-dialog.unprocessed').shiki_dialog().process()
    $('.b-message.unprocessed').shiki_message().process()

  $('.l-page').on 'ajax:success', '.messages-postloader', (e, data) ->
    $data = $("#{data.postloader}#{data.content}")
    $(@).replaceWith $data
    $('.b-message.unprocessed').shiki_message().process()
