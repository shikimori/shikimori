page_load 'collections_new', 'collections_create', ->
  new Collections.Edit '.new_collection'

page_load 'collections_edit', 'collections_update', ->
  new Collections.Edit '.edit_collection'
