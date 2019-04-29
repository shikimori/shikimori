import EditStyles from 'views/styles/edit'

pageLoad 'profiles_edit', ->
  # account page
  # if $('.edit-page.account').exists()

  # profile page
  if $('.edit-page.profile').exists()
    $('.b-shiki_editor').shikiEditor()

  # styles page
  if $('.edit-page.styles').exists()
    styles_page()

  # list & misc page
  if $('.edit-page.list, .edit-page.misc').exists()
    list_and_misc_page()

  # list page
  # if $('.edit-page.list').exists()

  if $('.edit-page.ignored_topics, .edit-page.ignored_users')
    ignores_page()

styles_page = ->
  new EditStyles '.b-edit_styles'

  $('#user_preferences_body_width').on 'change', ->
    $(document.body)
      .removeClass('x1000')
      .removeClass('x1200')
      .addClass($(@).val())

list_and_misc_page = ->
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

ignores_page = ->
  $('.b-editable_grid .actions .b-js-link')
    .on 'ajax:before', ->
      $(@).hide()
      $('<div class="ajax-loading vk-like"></div>').insertAfter @
    .on 'ajax:success', ->
      $(@).closest('tr').remove()

  $('.user_ids').completableVariant()
  $('.user_ids').focus() if $('.user_ids').is(':appeared')
  $('.user_ids').on 'keydown', (e) ->
    if e.keyCode is 10 || e.keyCode is 13
      $('.b-form').submit()
