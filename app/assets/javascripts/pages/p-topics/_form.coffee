LINKED_TYPE_USER_SELECT = '.topic_linked select.type'

pageLoad 'topics_new', 'topics_edit', 'topics_create', 'topics_update', ->
  $form = $ '.b-form.edit_topic, .b-form.new_topic'
  $topic_linked = $ '#topic_linked', $form
  $linked_type = $ '#topic_linked_type', $form

  $topic_link = $ '.topic-link', $form

  return unless $form.length

  initial_linked_type = $('#topic_linked_type').val() ||
    $('option', LINKED_TYPE_USER_SELECT).val()

  $(LINKED_TYPE_USER_SELECT)
    .on 'change', ->
      $linked_type.val @value
      $topic_linked
        .data autocomplete: (
          $topic_linked.data("#{@value.toLowerCase()}-autocomplete")
        )
        .attr placeholder: (
          $topic_linked.data("#{@value.toLowerCase()}-placeholder")
        )
        .trigger('flushCache')
    .val(initial_linked_type)
    .trigger('change')

  $('.b-shiki_editor', $form).shikiEditor()
  $('#topic_forum_id', $form).trigger('change')

  # сброс привязанного к топику
  $('.topic_linked .remove', $form).on 'click', ->
    $topic_link.find('a').remove()
    $('#topic_linked_id', $form).val('')
    # $('#topic_linked_type', $form).val('')
    $('#topic_linked', $form).val('')

    $topic_linked.show()
    $(LINKED_TYPE_USER_SELECT).show()
    $topic_link.hide()

  # выбор привязанного к топику
  $topic_linked.completable()
    .on 'autocomplete:success', (e, entry) ->
      $('#topic_linked_id', $form).val(entry.id)
      $('#topic_linked_type', $form).val($linked_type.val())
      @value = ''

      $topic_link.find('a').remove()
      $topic_link.prepend(
        "<a href='/#{$linked_type.val().toLowerCase()}s/#{entry.id}' \
        class='bubbled b-link'>#{entry.name}</a>"
      )
      $topic_link.process()

      $topic_linked.hide()
      $(LINKED_TYPE_USER_SELECT).hide()
      $('.topic-link', $form).show()

    .on 'keypress', (e) ->
      if e.keyCode == 10 || e.keyCode == 13
        e.preventDefault()
        false
