# добавление блока faye перед $insert_point
add_faye_placeholder = ($insert_point, id, insert_after) ->
  # точки вставки может не быть - означает, что элемемент принадлежит игнорируемому пользователю
  return null  unless $insert_point.length
  if insert_after
    $placeholder = $insert_point.next()
  else
    $placeholder = $insert_point.prev()
  unless $placeholder.hasClass("faye-loader")
    $placeholder = $("<div class=\"click-loader faye-loader\"></div>")
    $placeholder[(if insert_after then "insertAfter" else "insertBefore")]($insert_point).data "ids", []
  # данный элемент уже учтён
  return null  if _.contains($placeholder.data("ids"), id)
  $placeholder.data("ids").push id
  $placeholder

# подгрузка нового топика из Faye
$(".section-block").live "faye:success", (e, data) ->
  $this = $(this)
  topic_id = data.topic_id
  $topic = $this.find(".topic-" + topic_id)
  if $topic.length # блок топика уже существует, перенаправляем событие в топик
    $topic.trigger "faye:success", data
    return
  $placeholder = add_faye_placeholder($this.find(".topic-block").first(), topic_id)
  return false  unless $placeholder
  $placeholder.data "href", "/topics/chosen/" + $placeholder.data("ids").join(",")
  num = $placeholder.data("ids").length
  $placeholder.html p(num, "Добавлен или обновлён ", "Добавлены или обновлены ", "Добавлено или обновлено ") + num + p(num, " топик", " топика", " топиков")

  # уведомление о добавленном элементе через faye
  $(document.body).trigger "faye:added"


# подгрузка новых топиков по клику на лоадер пользователем
$(".section-block .faye-loader").live "ajax:success", (e, data) ->
  $(this).replaceWith data
  process_current_dom()


# подгрузка нового комментария из Faye
$(".topic-block").live "faye:success", (e, data) ->
  $this = $(this)
  comment_id = data.comment_id
  # данный коммент уже существует
  return false  if $this.find(".comment-" + comment_id).length
  if $this.hasClass("faye-top-add")
    $placeholder = add_faye_placeholder($this.find(".comment-block").first(), comment_id, true)
  else
    $placeholder = add_faye_placeholder($this.find(".comment-block").last(), comment_id)
  return false  unless $placeholder
  $placeholder.data "href", "/comments/chosen/" + $placeholder.data("ids").join(",") + ((if $this.hasClass("faye-top-add") then "/asc" else ""))
  num = $placeholder.data("ids").length
  $placeholder.html p(num, "Добавлен ", "Добавлены ", "Добавлено ") + num + p(num, " новый комментарий", " новых комментария", " новых комментариев")

  # уведомление о добавленном элементе через faye
  $(document.body).trigger "faye:added"
  false # чтобы обработчик раздела, лежащий выше, не сработал


# подгрузка новых комментариев по клику на лоадер пользователем
$(".topic-block .faye-loader").live "ajax:success", (e, data) ->
  $(this).replaceWith data
  process_current_dom()

  # уведомление о загруженном контенте
  $(document.body).trigger "faye:loaded"
  false # чтобы обработчик раздела, лежащий выше, не сработал
