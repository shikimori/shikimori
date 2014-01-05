$('.slide > div.settings').on 'ajax:success cache:success', (e, data) ->
  if !$('#import_form').length
    return

  # очистка списка
  # выбор варианта
  $('.list-cleanup .controls .link').on 'click', ->
    type = $(@).data 'type'
    $(@)
      .closest('.controls')
      .hide()

    $(@)
      .closest('.list-cleanup')
      .find(".form.#{type}")
      .show()

  # отмена
  $('.list-cleanup .cancel').on 'click', ->
    $('.list-cleanup .controls').show()
    $('.list-cleanup .form').hide()

  # сброс оценок
  # выбор варианта
  $('.scores-reset .controls .link').on 'click', ->
    type = $(@).data 'type'
    $(@)
      .closest('.controls')
      .hide()

    $(@)
      .closest('.scores-reset')
      .find(".form.#{type}")
      .show()

  # отмена
  $('.scores-reset .cancel').on 'click', ->
    $('.scores-reset .controls').show()
    $('.scores-reset .form').hide()


  # импорт / экспорт
  # выбор шага экспорта или импорта
  $('#import-export .control').on 'click', ->
    $('#import_form > div').hide()
      .filter('#'+$(@).data('next-step')).show()

  # отмена импорта
  $("#import_form .cancel").on "click", ->
    $("#import_form > div")
      .hide()
      .filter(":first").show()

  # экспорт списка
  $("#export_phase .control").on "click", ->
    $this = $(this)
    $.flash
      notice: "Начинается загрузка файла... Этот файл можно импортировать в MAL на странице http://myanimelist.net/import.php"
      removeTimer: 10000

    $("#shade").trigger "click"
    _.delay (->
      location.href = $this.data("target")
    ), 250

    $("#export_phase .cancel").trigger 'click'

  # выбор откуда импортировать: myanimelist.net или anime-planet.com
  $("#import_phase_1 .control").on "click", ->
    $("#import_service_name").html $(this).attr("title")
    $("#to_final_step").data "final-step", $(this).data("final-step")
    $("#import_phase_1").hide()
    $("#import_phase_2").show()


  # выбор типа импорта: аниме или манга
  $("#import_phase_2 .control").on "click", ->
    $("#import_form [name=klass]").val $(this).data("klass")
    $("#import_anime_planet_status").html $(this).data("anime-planet-status")
    $("#import_phase_2").hide()
    $("#import_phase_3").show()


  # выбор типа импорта: полный или частичный
  $("#import_phase_3 .control").on "click", ->
    $("#import_form [name=rewrite]").val $(this).data("rewrite")
    $("#import_phase_3").hide()
    if $("#to_final_step").data("final-step").match(/xml/)
      $("#import_xml").show()
    else
      $("#import_phase_4").show()
      $("#direct_mal", "#import_phase_4").hide()


  # переход на завершающую стадию импорта после указания логина в системе
  $("#import_phase_4 #to_final_step").on "click", ->
    $("#import_form [name=login]").val $("#import_form #import_login").val()
    if $(this).data("final-step").match(/mal/)
      fetch_list()
    else
      $("#import_phase_4").hide()
      $("#" + $(this).data("final-step")).show()


  # попытка импорта напрямую, минуя yql
  $("#import_phase_4 #direct_mal").on "click", ->
    $("#import_mal #mal_login").val $("#import_form #import_login").val().toLowerCase()
    $("#import_mal .submit").trigger "click"


  # импорт XML списка
  $("#import_xml .submit").on "click", ->
    $(this).parents("form").submit()
    _.delay (->
      $.flash
        notice: "Начинается импорт... Это может занять некоторое время. Пожалуйста, подождите и не обновляйте страницу."
        removeTimer: 300000

    ), 250


  # выбор типа импорта с anime-planet: полный или частичный
  $("#import_anime_planet .control").on "click", ->
    $this = $(this)
    $("#import_form [name=wont_watch_strategy]").val $this.data("wont-watch-strategy")
    $.flash
      notice: "Начинается импорт... Это может занять некоторое время. Пожалуйста, подождите и не обновляйте страницу."
      removeTimer: 300000

    _.delay (->
      $this.parents("form").submit()
    ), 250

  $("#import_form .submit.import").on "click", ->
    $this = $(this)
    $.flash
      notice: "Начинается импорт... Это может занять некоторое время. Пожалуйста, подождите и не обновляйте страницу."
      removeTimer: 300000

    _.delay (->
      $this.parents("form").submit()
    ), 250

  $("#import_phase_2 form").on "submit", ->
    $.cursorMessage()



# импорт анимесписка из MAL
#$(document).on 'click', '#import', ->
  #$('#shade').css(opacity: 0.5).show()
  #$('#import-phase-2').hide()
  #$('#import-phase-1').show()
  #show_form @

#$(document).on 'keypress', '#import-form input', (e) ->
  #$('#import-form .submit.get').trigger 'click' if e.keyCode is 13

#$('#import-form .submit.get').live 'click', ->
  #$.cursorMessage()
  #$.yql "SELECT * FROM json WHERE url=#{url}",
    #url: 'http://mal-api.com/animelist/' + $('#import-form #import_login').attr('value')
  #, (data) ->
    #try
      #$('#import-found').html data.query.results.json.anime.length
      #$('#import-phase-2').find('#data').attr 'value', JSON.stringify(_.map(data.query.results.json.anime, (v) ->
        #id: parseInt(v.id)
        #score: parseInt(v.score)
        #status: v.watched_status
        #episodes: parseInt(v.watched_episodes)
      #))
      #$('#import-phase-1').hide()
      #$('#import-phase-2').show()
    #catch e
      #$.flash alert: 'Не удалось получить список аниме. Возможно недоступен удаленный сервис.<br />Повторите попытку позже.'
    #$.hideCursorMessage()

  #false

#$('#import-phase-2 form').live 'submit', ->
  #$.cursorMessage()

