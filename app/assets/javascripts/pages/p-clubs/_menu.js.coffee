@on 'page:load', '.clubs', ->
  $menu = $('.l-menu')
  $actions_block = $('.actions', $menu)
  $invite_block = $menu.children('.invite')
  $nickname_input = $('#group_invite_dst_id', $invite_block)

  $('.invite', $actions_block).on 'click', ->
    $actions_block.hide()
    $invite_block.show()
    $nickname_input.focus()

  $('.cancel', $invite_block).on 'click', ->
    $actions_block.show()
    $invite_block.hide()

  $('form', $invite_block).on 'ajax:success', ->
    #$nickname_input.val('')
    #$('.cancel', $invite_block).click()

  $nickname_input.on 'keydown', (e) ->
    if e.keyCode == 27 # esc
      $('.cancel', $invite_block).click()
