# получение комментария
$comment = (node) ->
  $(node).closest('.b-abuse_request').find('.b-comment')

$moderation = (node) ->
  $(node).closest('.b-abuse_request').find('.b-request_resolution .moderation')

@on 'page:load', 'bans_index', ->
  # сокращение высоты инструкции
  $('.b-brief').check_height(150)

  # принятие или отказ запроса
  $('.moderation .take, .moderation .deny').on 'ajax:success', ->
    $comment(@).data('object')._reload()
    $moderation(@).hide()
