@on 'page:load', '.collections', ->
  if $('#collection_text').exists()
    $('.b-shiki_editor').shiki_editor()
