@on 'page:load', '.characters', ->
  # сокращение высоты описания
  $('.text').check_height(200)

  # нажатие кнопки Комментировать в меню
  $('.l-menu .comment').on 'click', ->
    $editor = $('.b-topic .editor-container .b-shiki_editor')
    if $editor.exists()
      $editor.focus()
    else
      $(document).one 'page:change', ->
        (-> $('.b-topic .editor-container .b-shiki_editor').focus()).delay()
      Turbolinks.visit $('.head .back').attr('href')

# редактирование персонажа
@on 'page:load', 'characters_edit', ->
  $('.b-shiki_editor')
    .shiki_editor()
    .on 'preview:params', ->
      body: $(@).data('object').$textarea.val()
      target_id: $('#change_item_id').val()
      target_type: $('#change_model').val()
