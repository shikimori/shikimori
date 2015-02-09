@on 'page:load', 'reviews_new', 'reviews_edit', 'reviews_create', 'reviews_update', ->
  $('.b-rate').rateable()
  $('.b-shiki_editor.unprocessed').shiki_editor()
