@on 'page:load', 'topics_index', ->
  $('.b-show_more').show_more()

  $banner = $('.naruto')

  # скрыть
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
