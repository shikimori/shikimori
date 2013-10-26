# инициализация топика
$('.ajax').live 'show:success', (e, data) ->
  _log "show:success"
  $('.review-block .rate-block').makeRateble()

$(document.body).on 'click', 'p.show-more', ->
  $(@).hide().next().show()
