@on 'page:load', '.characters', ->
  # сокращение высоты описания
  $('.text').check_height(200)

  # добавление в избранное
  $('.icon-actions .fav-add').on 'ajax:success', ->
    $(@).hide().next().show()
  # удаление из избранного
  $('.icon-actions .fav-remove').on 'ajax:success', ->
    $(@).hide().prev().show()
  # комментировать
  $('.icon-actions .new_comment').on 'click', ->
    $editor = $('.b-form.new_comment textarea')
    $.scrollTo $editor, ->
      $editor.focus()

# редактирование персонажа
@on 'page:load', 'characters_edit', ->
  $('.b-shiki_editor')
    .shiki_editor()
    .on 'preview:params', ->
      body: $(@).data('shiki_object').$textarea.val()
      target_id: $('#change_item_id').val()
      target_type: $('#change_model').val()
