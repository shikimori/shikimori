# формы вторизации/регистрации
window.show_form = ($form, $link) ->
  $('body').addClass 'with-hovered-form'
  $('#shade').trigger 'show'
  return if $form.is(':visible')

  # скрол наверх
  $('html, body').animate
    scrollTop: 0
  , (if is_tablet() then 0 else 250), 'easeOutBack'
  $form.show()
  form_top = $link.offset().top + 35
  form_height = $form.height()
  $form.css
    left: $link.offset().left - $form.width() + $link.width() - parseInt($link.parent().css('paddingRight').match(/\d+/)[0], 10)
    top: -1 * form_height - 10

  $form.animate
    top: $link.offset().top + $link.height()
  , (if is_tablet() then 0 else 500), 'easeOutBack'
  $form.find('input[type!=hidden]:first').focus()

window.hide_form = ->
  $form = $('.hover-form:visible')
  $form.stop true, true
  form_height = $form.height()

  $('body').removeClass 'with-hovered-form'
  $form.animate
    top: -1 * form_height - 10
  , (if is_tablet() then 0 else 400), ->
    $form.hide()

  $('#shade').trigger 'hide'

$ ->
  # скрытие формы по клику на бекграунд
  $(document.body).on 'click', '#shade, .hover-form .form-buttons .cancel', ->
    $('.hover-form').stop true, false
    hide_form()

  $(document.body).on 'show', '#shade', (e, opacity) ->
    $(@).css(opacity: opacity or 0.5).show()

  $(document.body).on 'hide', '#shade', (e, opacity) ->
    $(@).css(opacity: 0.0).hide()

  return if IS_LOGGED_IN
  # пока формы авторизации
  $('.usernav').on 'click', ->
    $('#sign_in').trigger 'click'
    false

  $('#sign_in').on 'ajax:success', (e, data) ->
    $(data).insertAfter $('body header').first()
    $(@).attr('data-remote', null).click(->
      $('.auth-form').trigger 'show'
    ).trigger 'click'

    # сабмит формы авторизации по кнопкам Вход/Регистрация
  $(document.body).on 'click', '.hover-form .form-buttons .login, .hover-form .form-buttons .register', ->
    $(@).parents('form').submit()

  # сабмит формы по ентеру
  $(document.body).on 'keypress', '.hover-form input', (e) ->
    $(@).parents('form').submit() if e.which is 13

  # скрытие формы по эскейпу
  $(document.body).on 'keydown', '.hover-form input', (e) ->
    $('.auth-form').trigger 'hide' if e.keyCode is 27

  # клик на oauth авторизацию
  $(document.body).on 'click', '.auth-form .oauth div', ->
    $this = $(@)
    _.delay ->
      $.flash notice: 'Выполняется авторизация...'
      window.location.href = $this.data('source')

  # клик на галочку регистрации
  $(document.body).on 'click', '#registration', ->
    $('.registration-trigger').hide()
    $('.registration-fields').show()
    $form = $(@).parents('form')
    $form.attr 'action', $form.data('register')
    $('.form-buttons .register', $form).show()
    $('.form-buttons .login', $form).hide()
    $('input[type!=hidden]', $form).first().focus()

  # показ/скрытие формы авторизации
  $(document.body).on 'show', '.auth-form', ->
    $('#registration', @).attr 'checked', false
    $('.registration-trigger', @).show()
    $('.registration-fields', @).hide()
    $('.form-buttons .register', @).hide()
    $('.form-buttons .login', @).show()
    $('form', @).attr 'action', $('form', @).data('login')
    $form = $(@)
    $link = $('.userbox')
    show_form $form, $link

  # после успешной авторизации
  $(document.body).on 'submit', '.auth-form form', ->
    $.flash notice: 'Выполняется авторизация...'

  $(document.body).on 'ajax:success', '.auth-form form', ->
    location.reload()
