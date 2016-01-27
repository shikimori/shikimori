@on 'page:load', 'profiles_edit', ->
  # account page
  if $('.edit-page.account').exists()
    $('.ignore-suggest').completable_variant()

  # profile page
  if $('.edit-page.profile').exists()
    $('.b-shiki_editor').shiki_editor()

  # styles page
  if $('.edit-page.styles').exists()
    $('#user_preferences_body_width').on 'change', ->
      $(document.body)
        .removeClass('x1000')
        .removeClass('x1200')
        .addClass($(@).val())

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
    $('.profile-action .controls .b-js-link').on 'click', ->
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

    # nickname changes cleanup
    # выбор варианта
    $('.nickname-changes .controls .b-js-link').on 'click', ->
      $('.nickname-changes .controls').hide()
      $('.nickname-changes .form').show()

    # отмена
    $('.nickname-changes .cancel').on 'click', ->
      $('.nickname-changes .controls').show()
      $('.nickname-changes .form').hide()

    # успешное завершение
    $('.nickname-changes a').on 'ajax:success', ->
      $('.nickname-changes .cancel').click()

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
      $this = $(@)
      $.flash
        notice: "Начинается загрузка файла... Этот файл можно импортировать в MAL на странице http://myanimelist.net/import.php"
        removeTimer: 10000

      $("#shade").trigger "click"
      (-> location.href = $this.data("target")).delay 250

      $("#export_phase .cancel").trigger 'click'

    # выбор откуда импортировать: myanimelist.net или anime-planet.com
    $("#import_phase_1 .control").on "click", ->
      type = $(@).data("final-step")
      $("#import_service_name").html $(@).attr("title")
      $("#to_final_step").data "final-step", type
      $("#import_phase_1").hide()

      if type == 'import_anime_planet'
        $("#import_phase_2 .control#anime").click()
      else
        $("#import_phase_2").show()

    # выбор типа импорта: аниме или манга
    $("#import_phase_2 .control").on "click", ->
      $("#import_form [name=klass]").val $(@).data("klass")
      $("#import_anime_planet_status").html $(@).data("anime-planet-status")
      $("#import_phase_2").hide()
      $("#import_phase_3").show()


    # выбор типа импорта: полный или частичный
    $("#import_phase_3 .control").on "click", ->
      $("#import_form [name=rewrite]").val $(@).data("rewrite")
      $("#import_phase_3").hide()
      if $("#to_final_step").data("final-step").match(/xml/)
        $("#import_xml").show()
      else
        $("#import_phase_4").show()
        $("#direct_mal", "#import_phase_4").hide()


    # переход на завершающую стадию импорта после указания логина в системе
    $("#import_phase_4 #to_final_step").on "click", ->
      $("#import_form [name=login]").val $("#import_form #import_login").val()
      if $(@).data("final-step").match(/mal/)
        fetch_list()
      else
        $("#import_phase_4").hide()
        $("#" + $(@).data("final-step")).show()


    # попытка импорта напрямую, минуя yql
    $("#import_phase_4 #direct_mal").on "click", ->
      $("#import_mal #mal_login").val $("#import_form #import_login").val().toLowerCase()
      $("#import_mal .submit").trigger "click"


    # импорт XML списка
    $("#import_xml .submit").on "click", ->
      $(@).closest("form").submit()
      (->
        $.flash
          notice: "Начинается импорт... Это может занять некоторое время. Пожалуйста, подождите и не обновляйте страницу."
          removeTimer: 300000
      ).delay 250


    # выбор типа импорта с anime-planet: полный или частичный
    $("#import_anime_planet .control").on "click", ->
      $this = $(@)
      $("#import_form [name=wont_watch_strategy]").val $this.data("wont-watch-strategy")
      $.flash
        notice: "Начинается импорт... Это может занять некоторое время. Пожалуйста, подождите и не обновляйте страницу."
        removeTimer: 300000

      (-> $this.closest("form").submit()).delay 250

    $("#import_form .submit.import").on "click", ->
      $this = $(@)
      $.flash
        notice: "Начинается импорт... Это может занять некоторое время. Пожалуйста, подождите и не обновляйте страницу."
        removeTimer: 300000

      (-> $this.closest("form").submit()).delay 250

    $("#import_phase_2 form").on "submit", ->
      $.cursorMessage()

  # styles page
  if $('.edit-page.ignored_topics')
    $('.b-editable_grid .actions .b-js-link')
      .on 'ajax:before', ->
        $(@).hide()
        $('<div class="ajax-loading vk-like"></div>').insertAfter @
      .on 'ajax:success', ->
        $(@).closest('tr').remove()
