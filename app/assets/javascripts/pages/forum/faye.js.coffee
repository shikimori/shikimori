# добавление блока faye перед $insert_point
add_faye_placeholder = ($insert_point, id, insert_after) ->
  # точки вставки может не быть - означает, что элемемент принадлежит игнорируемому пользователю
  return null unless $insert_point.length
  if insert_after
    $placeholder = $insert_point.next()
  else
    $placeholder = $insert_point.prev()
  unless $placeholder.hasClass('faye-loader')
    $placeholder = $('<div class="click-loader faye-loader"></div>')
    $placeholder[(if insert_after then 'insertAfter' else 'insertBefore')]($insert_point).data 'ids', []

  # данный элемент уже учтён
  return null  if _.contains($placeholder.data("ids"), id)
  $placeholder.data('ids').push id
  $placeholder

# подгрузка нового топика из Faye
$(document).on 'faye:success', '.b-topics', (e, data) ->
  $this = $(@)
  topic_id = data.topic_id
  $topic = $this.find ".topic-#{topic_id}"

  if $topic.length # блок топика уже существует, перенаправляем событие в топик
    $topic.trigger 'faye:success', data
    return

  else if data.event != 'created'
    return

  $placeholder = add_faye_placeholder($this.find('.topic-block').first(), topic_id)
  return false unless $placeholder
  $placeholder.data href: "/topics/chosen/#{$placeholder.data("ids").join ","}"
  num = $placeholder.data("ids").length
  $placeholder.html p(num, "Добавлен или обновлён ", "Добавлены или обновлены ", "Добавлено или обновлено ") + num + p(num, " топик", " топика", " топиков")

  # уведомление о добавленном элементе через faye
  $(document.body).trigger "faye:added"

# обновлени информации о комментарии из Faye
$(document).on 'faye:success', '.topic-block', (e, data) ->
  $comment = $(@).find(".comment-#{data.comment_id}")

  switch data.event
    when 'created'
      comment_created data, $(@), $comment

    #when 'updated'
      #comment_updated data, $(@), $comment

    when 'deleted'
      comment_deleted data, $(@), $comment
  false # чтобы обработчик раздела, лежащий выше, не сработал

# комментарий создан
comment_created = (data, $node, $comment) ->
  return if $comment.length # данный комментарий уже существует

  $placeholder = if $node.hasClass("faye-top-add")
    add_faye_placeholder $node.find('.comment-block').first(), data.comment_id, true
  else
    add_faye_placeholder $node.find('.comment-block').last(), data.comment_id
  return unless $placeholder

  $placeholder.data href: "/comments/chosen/" + $placeholder.data("ids").join(",") + ((if $node.hasClass("faye-top-add") then "/asc" else ""))

  num = $placeholder.data('ids').length
  $placeholder.html p(num, 'Добавлен ', 'Добавлены ', 'Добавлено ') + num + p(num, ' новый комментарий', ' новых комментария', ' новых комментариев')

  # уведомление о добавленном элементе через faye
  $(document.body).trigger "faye:added"
  if $placeholder.is(':appeared') && !$('textarea:focus').length
    $placeholder.click()

## комментарий обновлён
#comment_updated = (data, $node, $comment) ->
  #$comment.find('.is_updated').remove()
  #$comment.append "<div class='is_updated' data-href='/comments/#{data.comment_id}'>
    #<div><span>Комментарий изменён пользователем</span><a class='actor' href='/#{data.actor}'><img src='#{data.actor_avatar}' /><span>#{data.actor}</span></a>.</div>
    #<div>Кликните для обновления.</div>
  #</div>"

# комментарий удалён
comment_deleted = (data, $node, $comment) ->
  $comment.replaceWith "<div class='b-comment-info'><span>Комментарий удалён пользователем</span><a href='/#{data.actor}'><img src='#{data.actor_avatar}' /><span>#{data.actor}</span></a></div>"

## перезагрузка обновлённого комментария по клику на него
#$(document).on 'click', '.topic-block .is_updated', ->
  #$.get $(@).data('href'), (response) =>
    #$(@).closest('.comment-block').replaceWith response

# подгрузка новых топиков по клику на лоадер пользователем
$(document).on 'ajax:success', '.b-topics .faye-loader', (e, data) ->
  $(@).replaceWith data
  process_current_dom()

# подгрузка новых комментариев по клику на лоадер пользователем
$(document).on 'ajax:success', '.b-topic .faye-loader', (e, data) ->
  $(@).replaceWith data
  process_current_dom()

  # уведомление о загруженном контенте
  $(document.body).trigger 'faye:loaded'
  false # чтобы обработчик раздела, лежащий выше, не сработал
