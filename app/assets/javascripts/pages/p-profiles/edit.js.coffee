@on 'page:load', 'profiles_edit', ->
  # account page
  if $('.edit-page.account').exists()
    $('.avatar-delete').on 'click', ->
      $(@)
        .closest('form')
        .find('.b-input.file #user_avatar')
        .replaceWith("<p class=\"b-nothing_here\">сохраните настройки профиля</p><input type=\"hidden\" name=\"user[avatar]\" value=\"blank\" />")

      $(@).closest('.avatar-edit').remove()

    $('.ignore-suggest').completable_variant()

  # profile page
  if $('.edit-page.profile').exists()
    $('.b-shiki_editor').shiki_editor()

  # styles page
  if $('.edit-page.styles').exists()
    $page_background = $('#user_preferences_page_background')
    $page = $('.l-page')
    $('.range-slider')
      .noUiSlider
        range:
          min: 0
          max: 12
        start: parseFloat($page_background.val()) || 0
      .on 'slide', ->
        value = $(@).val()
        $page_background.val(value)
        ceiled_value = 255 - Math.ceil(value)
        $page.css('background-color', "rgb(#{ceiled_value},#{ceiled_value},#{ceiled_value})")

    $body = $('body')
    $body_background = $('#user_preferences_body_background')
    $('.backgrounds .present-backgrounds li').on 'click', ->
      value = $(@).data('background')
      $body_background.val("url(#{value}) repeat").trigger('change')

    $body_background.on 'change', ->
      $body.css background: @value

    $('#user_preferences_page_border').on 'change', ->
      $('body').toggleClass 'bordered', $(@).prop('checked')

  # list & misc page
  if $('.edit-page.misc, .edit-page.list').exists()
    # восстановление залокированных рекомендаций
    # выбор варианта
    $('.profile-action .controls .link').on 'click', ->
      type = $(@).data 'type'
      $(@).closest('.controls')
        .hide()

      $(@).closest('.profile-action')
        .find(".form.#{type}")
        .show()

    # отмена
    $('.profile-action .cancel').on 'click', ->
      $(@).closest('.profile-action')
        .find('.controls')
        .show()
      $(@).closest('.profile-action')
        .find('.form')
        .hide()

    # успешное завершение
    $('.profile-action a').on 'ajax:success', ->
      $(@).closest('.profile-action')
        .find('.cancel')
        .click()

  # list page
  if $('.edit-page.list').exists()
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
