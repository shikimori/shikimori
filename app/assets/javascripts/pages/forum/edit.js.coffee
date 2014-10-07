$('.ajax').live 'new:success edit:success', (e, data) ->
  _log 'edit/new:success'

  $((if e.type is 'new:success' then '#topic_data_title' else '#topic_data_text')).focus()
  $('.linked-suggest').completable 'Название аниме или манги...', linked_complete

  $topic_type = $('[name="topic[type]"]:checked')
  unless $topic_type.length
    $topic_type = $('[name="topic[type]"]').first()
  $topic_type.trigger 'click', [true]

  $upload = $(@).find('.drag-here-placeholder')
  $wall = $upload.find('.wall-container')
      .shiki_wall()

  $upload.find('.wall a')
      .fancybox $.galleryOptions

  $upload.shikiFile
      progress: $upload.find('.b-upload_progress')
      input: $upload.find('input[type=file]')
    .on 'upload:success', (e, data) ->
      $("<a href='#{data.url}' rel='new-wall' data-user_image_id='#{data.id}' class='image-container'>" + "<span class='image-delete hidden' title='Удалить картинку'></span>" + "<span class='image-delete-confirm hidden' title='Подтвердить удаление'></span>" + "<span class='image-delete-cancel hidden' title='Отменить удаление'></span>" + "<img src='#{data.preview}' />" + "</a>")
          .appendTo $wall
      $wall.shiki_wall()
      _.delay ->
          $wall.shiki_wall()
        , 100

  # после загрузки страницы на отмену привязываем особый обработчик
  $('.comment-block .item-cancel').on 'click', ->
    History.pushState null, null, $(@).attr('action').replace(/^http:\/\/.*?\//, '/')
    false

# автозаполнение привязанного аниме / манги
linked_complete = (e, id, text, label) ->
  return unless id && text
  is_anime = $('.linked-suggest').data('autocomplete').indexOf('anime') isnt -1
  $('.linked-selected').html "<a href='/#{(if is_anime then 'animes' else 'mangas')}/#{id}' class='bubbled' data-remote='true'>#{text}</a>"
  $('.linked-selected-right').html "<a href='/#{(if is_anime then 'animes' else 'mangas')}/#{id}/edit/videos'>добавить видео</a>"
  $('#topic_linked_id').val id
  $('#topic_linked_type').val (if is_anime then 'Anime' else 'Manga')
  process_current_dom()

# сброс привязанного аниме манги по измененю инпута автодополнения
$(document).on 'keypress', '.linked-suggest', ->
  $('#topic_linked_id').val ''
  $('#topic_linked_type').val $(@).val()
  $('.linked-selected').html ''

# клик по картинке
$(document).on "click", ".shiki-wall a", (e) ->
  false

# "удаление" картинки
$(document).on "click", ".shiki-wall .image-delete-confirm", (e) ->
  $wall = $(@).parents(".shiki-wall")
  $(@).closest("a").remove()
  $wall.css(
    width: ''
    height: ''
  ).find("img").css
    width: ''
    height: ''

  $wall.shiki_wall()
  false

# переключение типа новости - аниме/манга
$(document).on 'click', "input[name=\"topic[type]\"]", (e, no_keypress) ->
  selected = $(@).val().replace('News', '').toLowerCase()
  $suggest = $('.linked-suggest')
  $label = $('.linked-label')
  if selected is 'anime'
    $label.html 'Аниме'
    $suggest.data 'autocomplete', $suggest.data('autocomplete').replace('manga', 'anime')
  else
    $label.html 'Манга'
    $suggest.data 'autocomplete', $suggest.data('autocomplete').replace('anime', 'manga')
  $('.linked-suggest').trigger 'keypress'  unless no_keypress

# создание/редактирование топика
$('.new_topic .item-apply, .edit_topic .item-apply').live "click", (e, data) ->
  $form = $(@).parents("form")
  $posters = $(".wall-ids").empty()

  # постеры к новости
  $('.drag-here-placeholder a').map(->
    $(@).data "user_image_id"
  ).each (index, id) ->
    $posters.append "<input type=\"hidden\" name=\"wall[]\" value=\"" + id + "\"/>"

  $form.submit()

# топик создан/отредактирован успешно
$('.new_topic, .edit_topic, .edit_contest_comment').live 'ajax:success', (e, data) ->
  History.pushState null, null, data.url
