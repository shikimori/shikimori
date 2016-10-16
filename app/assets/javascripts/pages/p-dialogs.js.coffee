@on 'page:load', 'dialogs_index', 'dialogs_show', ->
  $('textarea:appeared').focus()
