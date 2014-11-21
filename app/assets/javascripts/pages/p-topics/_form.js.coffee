@on 'page:load', 'topics_new', 'topics_edit', 'topics_create', 'topics_update', ->
  $form = $('.b-form.edit_topic, .b-form.new_topic')

  $('.b-shiki_editor', $form).shiki_editor()

  # сброс привязанного к топику
  $('.topic_linked .cleanup', $form).on 'click', ->
    $('.topic_linked .topic-link, .topic_linked .topic-video', $form).empty()
    $('#topic_linked_id', $form).val('')
    $('#topic_linked_type', $form).val('')
    $('#topic_linked', $form).val('')

  # выбор привязанного к топику
  $('#topic_linked', $form).completable()
    .on 'autocomplete:success', (e, entry) ->
      $('#topic_linked_id', $form).val(entry.id)
      $('#topic_linked_type', $form).val(if is_anime() then 'Anime' else 'Manga')
      @value = ''

      type = if is_anime() then 'anime' else 'manga'
      $('topic-link', $form)
        .html("<a href='/#{type}s/#{entry.id}' class='bubbled'>#{entry.name}</a>")
        .process()

      $('.topic-video', $form).html "<a href='/#{type}s/#{entry.id}/edit/videos' target='_blank'>добавить видео</a>"

  # создание/редактирование топика
  $form.on 'submit', ->
    $posters = $('.wall-ids', $form).empty()

    # постеры к новости
    $('.drag-here-placeholder a', $form).map(->
      $(@).data 'user_image_id'
    ).each (index, id) ->
      $posters.append "<input type=\"hidden\" name=\"wall[]\" value=\"#{id}\"/>"

  # загрузка постера
  $upload = $('.topic_posters .drag-here-placeholder', $form)
  $wall = $upload.find('.b-shiki_wall')

  $upload
    .shikiFile
      progress: $upload.find('.b-upload_progress')
      input: $upload.find('input[type=file]')
    .on 'upload:success', (e, data) ->
      $image = $("<a href='#{data.url}' rel='new-wall' class='b-image' data-user_image_id='#{data.id}'>
<img src='#{data.preview}' class=''>
<div class='mobile-edit'></div>
<div class='controls'>
  <div class='delete' title='Удалить картинку'></div>
  <div class='confirm' title='Подтвердить удаление'></div>
  <div class='cancel' title='Отменить удаление'></div>
</div>
</a>").appendTo($wall)

      $('.confirm', $image).on 'click', ->
        $image.remove()
        reset_wall $wall
        false

      reset_wall $wall

reset_wall = ($wall) ->
  $wall.find('img').css(width: '', height: '')
  $wall.addClass('unprocessed').shiki_wall()

is_anime = ->
  $('#topic_type').val() == 'AnimeNews'

is_manga = ->
  $('#topic_type').val() == 'MangaNews'
