@on 'page:load', 'animes_edit', 'mangas_edit', ->
  $('.b-shiki_editor')
    .shiki_editor()
    .on 'preview:params', ->
      body: $(@).data('object').$textarea.val()
      target_id: $('#change_item_id').val()
      target_type: $('#change_model').val()
