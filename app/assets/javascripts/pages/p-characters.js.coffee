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

# арт с имиджборд по персонажу
@on 'page:load', 'characters_art', ->
  $('.b-gallery').imageboard()

# редактирование персонажа
@on 'page:load', 'characters_edit', ->
  $('.b-shiki_editor')
    .shiki_editor()
    .on 'preview:params', ->
      body: $(@).shiki().$textarea.val()
      target_id: $('#change_item_id').val()
      target_type: $('#change_model').val()

  if $('.edit-page.tags').exists()
    $('#user_change_value')
      .completable()
      .on 'autocomplete:success autocomplete:text', (e, result) ->
        @value = if Object.isString(result) then result else result.value
        $('.b-gallery').data(tags: @value)
        $('.b-gallery').shiki().refresh()

    $('.b-gallery').imageboard()
