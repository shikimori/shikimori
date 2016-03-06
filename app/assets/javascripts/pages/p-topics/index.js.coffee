@on 'page:load', 'topics_index', 'topics_show', 'topics_new', 'topics_edit', 'topics_create', 'topics_update', ->
  if $('.b-animes-menu').exists()
    init_animes_menu()
  else
    $('.b-show_more').show_more()

@on 'page:load', 'topics_index', ->
  $banner = $('.naruto, .titans')

  # скрыть баннер
  $('.delete', $banner).on 'click', ->
    $.cookie $banner.data('cookie-name'), true, {expires: 9999, path: '/'}
    $banner.addClass('deletable')

  # отмена скрытия
  $('.cancel', $banner).on 'click', ->
    $banner
      .removeClass('deletable')
      .removeClass('mobile-editing')

  # подтверждение скрытия
  $('.confirm', $banner).on 'click', ->
    $banner
      .removeClass('deletable')
      .addClass('deleted')

  # настройки форума
  $form = $('form.edit_user_preferences')
  $form
    .on 'change', 'input', ->
      $form.submit()

    .on 'ajax:before', ->
      $('.ajax-loading', $form).show()
      $('.reload', $form).hide()

    .on 'ajax:complete', ->
      $('.ajax-loading', $form).hide()
      $('.reload', $form).show()
