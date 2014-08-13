# инициализация топика
$('.ajax').live 'show:success', (e, data) ->
  _log "show:success"

$(document.body).on 'click', 'p.show-more', ->
  $(@).hide().next().show()
