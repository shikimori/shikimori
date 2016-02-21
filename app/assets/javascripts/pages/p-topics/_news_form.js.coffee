@on 'page:load', 'topics_new', 'topics_edit', 'topics_create', 'topics_update', ->
  $form = $ '.b-form.edit_topic, .b-form.new_topic'
  $linked_id = $ '#topic_linked_id', $form
  $linked_type = $ '#topic_linked_type', $form

  # загрузка постера
  $upload = $ '.topic_posters .b-dropzone', $form
  $wall = $upload.find('.b-shiki_wall')

  $upload
    .shikiFile
      progress: $upload.find('.b-upload_progress')
      input: $upload.find('input[type=file]')
    .on 'upload:success', (e, data) ->
      $image = $("<a href='#{data.url}' rel='new-wall' class='b-image b-link' id='#{data.id}'>\
<img src='#{data.preview}' class=''>
<div class='mobile-edit'></div><div class='controls'>
<div class='delete' title='Удалить картинку'></div>\
<div class='confirm' title='Подтвердить удаление'></div>\
<div class='cancel' title='Отменить удаление'></div></div></a>").appendTo($wall)

      $('.confirm', $image).on 'click', ->
        remove_image $image, $wall

      reset_wall $wall

  $('.b-image .confirm', $upload).on 'click', ->
    remove_image $(@).closest('.b-image').remove(), $wall

  # загрузка видео
  $topic_video = $ '.topic_video', $form
  $topic_video_form = $ '.form', $topic_video
  $topic_video_video = $ '.video', $topic_video
  $topic_video_remove = $ '.remove', $topic_video

  $attach = $ '.attach', $topic_video_form
  $errors = $ '.errors', $topic_video_form

  # прикрепление видео
  $attach.on 'click', ->
    anime_id = linked_anime_id($linked_type, $linked_id)
    url = $attach.data('url').replace('ANIME_ID', anime_id || 0)
    form =
      'video[anime_id]': anime_id
      'video[url]': $('#topic_video_url', $topic_video_form).val()
      'video[kind]': $('#topic_video_kind', $topic_video_form).val()
      'video[name]': $('#topic_video_name', $topic_video_form).val()

    $topic_video.addClass 'b-ajax'

    $.post
      url: url
      data: form
      dataType: 'json'
    .success (result) ->
      $topic_video.removeClass 'b-ajax'

      if result.errors
        $errors.show().html result.errors.join(', ')
      else
        $errors.hide()

        $topic_video.data video_id: result.video_id
        $topic_video_form.hide()
        $topic_video_video
          .show()
          .html(result.content)
          .process()
        $topic_video_remove.removeClass 'hidden'

  # удаление видео
  $topic_video_remove.on 'click', ->
    $topic_video.data video_id: null
    $topic_video_form.show()
    $topic_video_video.hide().empty()
    $topic_video_remove.addClass 'hidden'

  # создание/редактирование топика
  $form.on 'submit', ->
    $attachments = $('.attachments', $form).empty()

    # постеры
    $('.b-dropzone a', $form)
      .map -> $(@).attr('id')
      .each (index, id) ->
        $attachments.append "<input type=\"hidden\" name=\"topic[wall_ids][]\" value=\"#{id}\"/>"

    # видео
    video_id = $topic_video.data 'video_id'
    if video_id
      $attachments.append "<input type=\"hidden\" name=\"topic[video_id]\" value=\"#{video_id}\"/>"

remove_image = ($image, $wall) ->
  $image.remove()
  reset_wall $wall
  false

reset_wall = ($wall) ->
  $wall.find('img').css(width: '', height: '')
  $wall.addClass('unprocessed').shiki_wall()

linked_anime_id = ($linked_type, $linked_id) ->
  $linked_id.val() if $linked_type.val() == 'Anime'
