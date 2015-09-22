# получение комментария
$comment = (node) ->
  $(node).closest('.b-abuse_request').find('.b-comment')

$moderation = (node) ->
  $(node).closest('.b-abuse_request').find('.b-request_resolution .moderation')

# раскрытие информации о загрузке видео
@on 'page:load', 'anime_video_reports_index', 'profiles_videos', ->
  $('.l-page').on 'click', '.b-log_entry.video .collapsed', ->
    $player = $(@).parent().find('.player')

    if $player.data 'html'
      $player
        .html($player.data 'html')
        .data(html: '')

# страницы модерации
@on 'page:load', 'bans_index', 'abuse_requests_index', 'versions_index', 'review_index', ->
  # сокращение высоты инструкции
  $('.b-brief').check_height(150)

  ## NOTE: порядок следования функций ajax:success важен
  ## редактирвоание коммента
  #$(document.body).on 'ajax:success', '.shiki-editor', (e, data) ->
    #$(".comment-#{data.id}").replaceWith data.html

  ## принятие или отказ запроса
  #$(document.body).on 'ajax:success', '.request-control .take, .request-control .deny', ->
    #reload $comment(@)

  # кнопка бана или предупреждения
  $('.moderation .ban, .moderation .warn').on 'ajax:success', (e, html) ->
    $moderation(@).find('.moderation-buttons').hide()

    $form = $(@).closest('.b-abuse_request').find('.ban-form')
    $form.html html
    if $(@).hasClass 'warn'
      $form.find('#ban_duration').val '0m'

      if $(@).closest('.b-abuse_request').find('.b-spoiler_marker').length
        $form.find('#ban_reason').val 'спойлеры'

    # закрытие формы бана
    $('.cancel', $form).on 'click', ->
      $moderation(@).find('.moderation-buttons').show()
      $(@).closest('.ban-form').empty()

    # сабмит формы бана пользователю
    $form.on 'ajax:success', (e) ->
      $comment(@).shiki()._reload()
      $(@).closest('.ban-form').empty()
      $moderation(@).find('.moderation-buttons').hide()

# информация о пропущенных видео
@on 'page:load', 'moderations_missing_videos', ->

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
