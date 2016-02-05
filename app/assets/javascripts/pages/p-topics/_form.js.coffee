LINKED_TYPE_USER_SELECT = '.topic_linked select.type'

@on 'page:load', 'topics_index', ->
  $('form.edit_user_preferences')
    .on 'change', 'input', ->
      $(@).closest('form').submit()

    .on 'ajax:before', ->
      $('.b-forums .ajax-loading').show()
      $('.b-forums .reload').hide()

    .on 'ajax:complete', ->
      $('.b-forums .ajax-loading').hide()
      $('.b-forums .reload').show()

@on 'page:load', 'topics_index', 'topics_show', 'topics_new', 'topics_edit', 'topics_create', 'topics_update', ->
  if $('.b-animes-menu').exists()
    init_animes_menu()
  else
    $('.b-show_more').show_more()

@on 'page:load', 'topics_new', 'topics_edit', 'topics_create', 'topics_update', ->
  $form = $ '.b-form.edit_topic, .b-form.new_topic'
  $topic_linked = $ '#topic_linked', $form
  $linked_type = $ '#topic_linked_type', $form

  initial_linked_type = $('#topic_linked_type').val() ||
    $('option', LINKED_TYPE_USER_SELECT).val()
  $(LINKED_TYPE_USER_SELECT)
    .on 'change', ->
      console.log @value
      $linked_type.val @value
      $topic_linked
        .data autocomplete: $topic_linked.data("#{@value.toLowerCase()}-autocomplete")
        .attr placeholder: $topic_linked.data("#{@value.toLowerCase()}-placeholder")
        .trigger('flushCache')
    .val(initial_linked_type)
    .trigger('change')

  # переключение раздела
  $('#topic_forum_id', $form).on 'change', ->
    $topic_linked
      .data autocomplete: $topic_linked.data("#{$linked_type.val().toLowerCase()}-autocomplete")
      .attr placeholder: $topic_linked.data("#{$linked_type.val().toLowerCase()}-placeholder")
      .trigger('flushCache')

  $('.b-shiki_editor', $form).shiki_editor()
  $('#topic_forum_id', $form).trigger('change')

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
      $('#topic_linked_type', $form).val($linked_type.val())
      @value = ''

      $('.topic-link', $form)
        .html("<a href='/#{$linked_type.val().toLowerCase()}s/#{entry.id}' class='bubbled b-link'>#{entry.name}</a>")
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
    $('.b-dropzone a', $form)
      .map -> $(@).attr('id')
      .each (index, id) ->
        $posters.append "<input type=\"hidden\" name=\"topic[wall_ids][]\" value=\"#{id}\"/>"

  # загрузка постера
  $upload = $('.topic_posters .b-dropzone', $form)
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
