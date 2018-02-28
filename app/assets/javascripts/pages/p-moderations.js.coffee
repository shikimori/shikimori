DatePicker = require 'views/application/date_picker'

# получение комментария
$comment = (node) ->
  $(node).closest('.b-abuse_request').find('.b-comment')

$moderation = (node) ->
  $(node).closest('.b-abuse_request').find('.b-request_resolution .moderation')

date_picker = ->
  if $('.date-filter').exists()
    picker = new DatePicker('.date-filter')
    picker.on 'date:picked', ->
      new_url = new URI(location.href).setQuery('created_on', @value).href()
      Turbolinks.visit new_url

# раскрытие информации о загрузке видео
page_load 'anime_video_reports_index', 'profiles_videos', ->
  date_picker()

  $('.l-page').on 'click', '.b-log_entry.video .collapsed', ->
    $player = $(@).parent().find('.player')

    if $player.data 'html'
      $player
        .html($player.data 'html')
        .data(html: '')


# страница модерации правок
page_load 'versions_index', 'users_index', ->
  date_picker()

# страницы модерации
page_load 'bans_index', 'abuse_requests_index', 'versions_index', 'review_index', 'anime_video_reports_index', ->
  # сокращение высоты инструкции
  $('.b-brief').check_height max_height: 150

  $('.expand-all').on 'click', ->
    $(@).parent().next().next().find('.collapsed.spoiler:visible').click()
    $(@).remove()

# информация о пропущенных видео
page_load 'moderations_missing_videos', ->
  $('.missing-video .show-details').on 'click', ->
    $(@).parent()
      .find('.details')
      .toggleClass('hidden')
    false

  $('.missing-video .show-details').one 'click', ->
    $.get $(@).data('episodes_url'), (html) =>
      $(@).parent()
        .find('.details')
        .html(html)
    false
