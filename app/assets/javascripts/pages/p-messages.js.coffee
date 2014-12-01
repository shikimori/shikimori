@on 'page:load', 'messages_index', ->
  $('.b-message.unprocessed').shiki_message()

  $('.l-page').on 'postloader:success', '.b-postloader', (e, $data) ->
    $('.b-message.unprocessed', $data).shiki_message()

