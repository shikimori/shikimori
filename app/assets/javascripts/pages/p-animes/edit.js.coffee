@on 'page:load', 'animes_edit', 'mangas_edit', ->
  if $('.edit-page.description').exists()
    $('.b-shiki_editor')
      .shiki_editor()
      .on 'preview:params', ->
        body: $(@).data('object').$textarea.val()
        target_id: $('#change_item_id').val()
        target_type: $('#change_model').val()

  if $('.edit-page.screenshots').exists()
    $('.c-screenshot').shiki_image()
