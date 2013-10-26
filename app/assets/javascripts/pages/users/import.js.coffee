# импорт анимесписка из MAL
$(document).on 'click', '#import', ->
  $('#shade').css(opacity: 0.5).show()
  $('#import-phase-2').hide()
  $('#import-phase-1').show()
  show_form @

$(document).on 'keypress', '#import-form input', (e) ->
  $('#import-form .submit.get').trigger 'click' if e.keyCode is 13

$('#import-form .submit.get').live 'click', ->
  $.cursorMessage()
  $.yql "SELECT * FROM json WHERE url=#{url}",
    url: 'http://mal-api.com/animelist/' + $('#import-form #import_login').attr('value')
  , (data) ->
    try
      $('#import-found').html data.query.results.json.anime.length
      $('#import-phase-2').find('#data').attr 'value', JSON.stringify(_.map(data.query.results.json.anime, (v) ->
        id: parseInt(v.id)
        score: parseInt(v.score)
        status: v.watched_status
        episodes: parseInt(v.watched_episodes)
      ))
      $('#import-phase-1').hide()
      $('#import-phase-2').show()
    catch e
      $.flash alert: 'Не удалось получить список аниме. Возможно недоступен удаленный сервис.<br />Повторите попытку позже.'
    $.hideCursorMessage()

  false

$('#import-phase-2 form').live 'submit', ->
  $.cursorMessage()
