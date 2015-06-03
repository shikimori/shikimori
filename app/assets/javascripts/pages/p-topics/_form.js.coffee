@on 'page:load', 'topics_new', 'topics_edit', 'topics_create', 'topics_update', ->
  $form = $('.b-form.edit_topic, .b-form.new_topic')
  $topic_linked = $('#topic_linked', $form)

  # переключение раздела
  $('#topic_section_id', $form).on 'change', ->
    $topic_linked
      .data autocomplete: $topic_linked.data("#{linked_type().toLowerCase()}-autocomplete")
      .attr placeholder: $topic_linked.data("#{linked_type().toLowerCase()}-placeholder")
      .trigger('flushCache')

  $('.b-shiki_editor', $form).shiki_editor()
  $('#topic_section_id', $form).trigger('change')

  # сброс привязанного к топику
  $('.topic_linked .cleanup', $form).on 'click', ->
    $('.topic_linked .topic-link, .topic_linked .topic-video', $form).empty()
    $('#topic_linked_id', $form).val('')
    $('#topic_linked_type', $form).val('')
    $('#topic_linked', $form).val('')

  # выбор привязанного к топику
  $topic_linked.completable()
    .on 'autocomplete:success', (e, entry) ->
      $('#topic_linked_id', $form).val(entry.id)
      $('#topic_linked_type', $form).val(linked_type())
      @value = ''

      $('.topic-link', $form)
        .html("<a href='/#{linked_type().toLowerCase()}s/#{entry.id}' class='bubbled b-link'>#{entry.name}</a>")
        .process()
      #$('.topic-video', $form).html "<a class='b-link' href='/#{type}s/#{entry.id}/edit/videos' target='_blank'>добавить видео</a>"

    .on 'keypress', (e) ->
      if e.keyCode == 10 || e.keyCode == 13
        e.preventDefault()
        false


  # создание/редактирование топика
  $form.on 'submit', ->
    $posters = $('.wall-ids', $form).empty()

    # постеры к новости
    $('.drag-here-placeholder a', $form)
      .map -> $(@).attr('id')
      .each (index, id) ->
        $posters.append "<input type=\"hidden\" name=\"wall[]\" value=\"#{id}\"/>"

  # загрузка постера
  $upload = $('.topic_posters .drag-here-placeholder', $form)
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

remove_image = ($image, $wall) ->
  $image.remove()
  reset_wall $wall
  false

reset_wall = ($wall) ->
  $wall.find('img').css(width: '', height: '')
  $wall.addClass('unprocessed').shiki_wall()

linked_type = ->
  if $('#topic_section_id').val() == '7'
    'Character'
  else if $('#topic_section_id').val() == '6'
    'Manga'
  else
    'Anime'
