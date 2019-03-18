pageLoad '.clubs', ->
  $menu = $('.b-clubs-menu')
  $actions_block = $('.club-actions', $menu)
  $invite_block = $menu.children('.invite')
  $nickname_input = $('#club_invite_dst_id', $invite_block)

  # нажатие Пригласить в клуб
  $('.invite', $actions_block).on 'click', ->
    $actions_block.hide()
    $invite_block.show()
    $nickname_input.focus()

  # отмена приглашения
  $('.cancel', $invite_block).on 'click', ->
    $actions_block.show()
    $invite_block.hide()

  # отправка приглашения
  $('form', $invite_block).on 'ajax:success', ->
    $nickname_input.val('')
    $('.cancel', $invite_block).click()

  # по ESC в инпуте отменяем приглашение
  $nickname_input.on 'keydown', (e) ->
    if e.keyCode == 27 # esc
      $('.cancel', $invite_block).click()

  # загрузка картинки
  $('.upload input', $menu).on 'change', ->
      $(@).closest('form').submit()
