# получение комментария
$comment = (node) ->
  $(node).closest('.abuse-request').find('.comment-block')

# перезагрузка коммента
reload = ($comment) ->
  id = $comment.data('id')

  $comment.animate opacity: 0.3

  $.get "/comments/#{id}", (data) ->
    $(".comment-#{id}").not($comment).replaceWith data

    $data = $(data).css opacity: 0.3
    $comment.replaceWith $data
    _.delay ->
      $data.animate opacity: 1

# скрытие кнопочек действий
hide_actions = (node) ->
  $(node).closest('.request-control').children('.moderation').hide()

# закрытие формы бана
$(document.body).on 'click', 'form.ban .form-cancel', ->
  $(@).closest('.request-control').children('.bracket-actions').show()
  $(@).closest('.ban-form').empty()

# NOTE: порядок следования функций ajax:success важен
# редактирвоание коммента
$(document.body).on 'ajax:success', '.shiki-editor', (e, data) ->
  $(".comment-#{data.id}").replaceWith data.html

# принятие или отказ запроса
$(document.body).on 'ajax:success', '.request-control .take, .request-control .deny', ->
  reload $comment(@)

# сабмит формы бана пользователю
$(document.body).on 'ajax:success', 'form.ban', (e, data) ->
  e.stopImmediatePropagation()
  $(".comment-#{data.comment_id}").html data.comment_html
  hide_actions @

# кнопка бана или предупреждения
$(document.body).on 'ajax:success', '.request-control .ban, .request-control .warn', (e, html) ->
  e.stopImmediatePropagation()
  $ban_form = $(@).closest('.abuse-request').find('.ban-form')

  $ban_form.html html
  if $(@).hasClass 'warn'
    $ban_form.find('#ban_duration').val '0m'

    if $(@).closest('.abuse-request').find('.spoiler-marker').length
      $ban_form.find('#ban_reason').val 'спойлеры'

# обработка аяксовой кнопочки
$(document.body).on 'ajax:success', '.request-control span', ->
  hide_actions @
