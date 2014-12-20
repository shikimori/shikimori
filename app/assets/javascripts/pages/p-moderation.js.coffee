# получение комментария
$comment = (node) ->
  $(node).closest('.b-abuse_request').find('.b-comment')

$moderation = (node) ->
  $(node).closest('.b-abuse_request').find('.b-request_resolution .moderation')

@on 'page:load', 'bans_index', 'abuse_requests_index', 'user_changes_index', 'review_index', 'anime_video_reports_index', ->
  # сокращение высоты инструкции
  $('.b-brief').check_height(150)

  # принятие или отказ запроса
  $('.moderation .take, .moderation .deny').on 'ajax:success', ->
    $comment(@).data('shiki_object')._reload()
    $moderation(@).hide()

  $('.p-anime_video_reports .collapsed').on 'click', ->
    $iframe = $('iframe', $(@).parent())
    $iframe.attr src: $iframe.data('url')

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
    $('.form-cancel', $form).on 'click', ->
      $moderation(@).find('.moderation-buttons').show()
      $(@).closest('.ban-form').empty()

    # сабмит формы бана пользователю
    $form.on 'ajax:success', (e) ->
      $comment(@).data('shiki_object')._reload()
      $(@).closest('.ban-form').empty()
      $moderation(@).find('.moderation-buttons').hide()
