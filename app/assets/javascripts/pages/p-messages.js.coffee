@on 'page:load', 'messages_index', ->
  process()
  $('.l-page').on 'postloader:success', '.b-postloader', process

process = ->
  $('.b-message.unprocessed').shiki_message()

  $('.item-request-confirm, .item-request-reject').on 'ajax:success', ->
    read_message $(@).closest('.b-message')

  $('.item-request-reject.friend-request').on 'click', ->
    read_message $(@).closest('.b-message')

read_message = ($message) ->
  $appear_marker = $message.find('.appear-marker').data disabled: false
  $message.trigger 'appear', [$appear_marker, true]
  $message.find('.main-controls').children(':not(.item-delete)').remove()
  $message.find('.main-controls').children('.item-delete').show()
