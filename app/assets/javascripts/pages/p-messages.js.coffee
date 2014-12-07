@on 'page:load', 'messages_index', ->
  process()

  $('.l-page').on 'postloader:success', '.b-postloader', (e, $data) ->
    process()

process = ->
  $('.b-message.unprocessed').shiki_message()

  $('.item-request-confirm, .item-request-reject').on 'ajax:success', ->
    $message = $(@).closest('.b-message')
    $message.trigger 'appear', [$message.find('.appear-marker'), true]

  $('.item-request-reject.friend-request').on 'click', ->
    $message = $(@).closest('.b-message')
    $message.trigger 'appear', [$message.find('.appear-marker'), true]
