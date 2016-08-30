@on 'page:load', 'dialogs_index', 'dialogs_show', ->
  $('textarea:appeared').focus()

  $('.l-page').on 'ajax:success', '.messages-postloader', (e, data) ->
    $data = $("#{data.postloader}#{data.content}").process data.JS_EXPORTS
    $(@).replaceWith $data
