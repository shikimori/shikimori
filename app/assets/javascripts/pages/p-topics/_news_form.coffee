import axios from 'helpers/axios'

pageLoad 'topics_new', 'topics_edit', 'topics_create', 'topics_update', ->
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
      $image = $(
        "<a href='#{data.url}' rel='new-wall' class='b-image b-link' \
        id='#{data.id}'>\
        <img src='#{data.preview}' class=''>
        <div class='mobile-edit'></div><div class='controls'>
        <div class='delete'></div>\
        <div class='confirm'></div>\
        <div class='cancel'></div></div></a>"
      ).appendTo($wall)

      $('.confirm', $image).on 'click', ->
        remove_image $image, $wall

      reset_wall $wall

  $('.b-image .confirm', $upload).on 'click', ->
    remove_image $(@).closest('.b-image').remove(), $wall

  # прикреплённое видео
  $topic_video = $ '.topic_video', $form

  if $topic_video.data 'video_id'
    attach_video {
      video_id: $topic_video.data('video_id')
      content: $topic_video.data('content')
    }, $topic_video, $wall

  # загрузка видео
  $topic_video_form = $ '.form', $topic_video

  $attach = $ '.attach', $topic_video_form

  # прикрепление видео
  $attach.on 'click', ->
    anime_id = linked_anime_id($linked_type, $linked_id)
    url = $attach.data('url').replace('ANIME_ID', anime_id || 0)
    form =
      video:
        anime_id: anime_id
        url: $('#topic_video_url', $topic_video_form).val()
        kind: $('#topic_video_kind', $topic_video_form).val()
        name: $('#topic_video_name', $topic_video_form).val()

    $topic_video.addClass 'b-ajax'

    axios.post(url, form).then (data) ->
      attach_video data.data, $topic_video, $wall

  # создание/редактирование топика
  $form.on 'submit', ->
    $attachments = $('.attachments', $form).empty()

    # постеры
    $('.b-dropzone a', $form)
      .map -> $(@).attr('id')
      .each (index, id) ->
        $attachments.append(
          "<input type=\"hidden\" name=\"topic[wall_ids][]\" value=\"#{id}\"/>"
        )

    # видео
    video_id = $topic_video.data 'video_id'
    if video_id
      $attachments.append(
        "<input type=\"hidden\" name=\"topic[video_id]\" \
        value=\"#{video_id}\"/>"
      )

remove_image = ($image, $wall) ->
  $image.remove()
  reset_wall $wall
  false

reset_wall = ($wall) ->
  $wall.find('img').css(width: '', height: '')
  new Wall.Gallery $wall

linked_anime_id = ($linked_type, $linked_id) ->
  $linked_id.val() if $linked_type.val() == 'Anime'

attach_video = (video_data, $topic_video, $wall) ->
  $topic_video_form = $ '.form', $topic_video
  $topic_video_remove = $ '.remove', $topic_video
  $topic_video_errors = $ '.errors', $topic_video

  $topic_video.removeClass 'b-ajax'

  if video_data.errors
    $topic_video_errors.show().html video_data.errors.join(', ')
  else
    $topic_video_errors.hide()

    $topic_video.data video_id: video_data.video_id
    $topic_video_form.hide()
    $topic_video_remove.removeClass 'hidden'

    $video = $(video_data.content).prependTo($wall)
    reset_wall $wall

    # удаление видео
    $topic_video_remove.one 'click', ->
      $topic_video.data video_id: null
      $topic_video_form.show()
      $topic_video_remove.addClass 'hidden'

      remove_image $video, $wall
