@on 'page:load', 'contests_edit', ->
  suggest_placeholder = if $('.edit.contest .member-suggest').data('member_type') == 'anime'
    'Название аниме...'
  else
    'Имя персонажа...'

  $('.edit.contest .member-suggest').completable suggest_placeholder
  $('.edit .proposing .hidden').removeClass 'hidden'

  # удаление элемента из опроса
  $('form').on 'click', '.item-delete', ->
    $(@).closest('li').remove()
    update_members_count()

  $('form .proposing .take').on 'click', ->
    $(@).parent().hide()
    $('.member-suggest').trigger 'autocomplete:success', [$(@).data('id'), $(@).data('text')]
    $('.member-suggest').trigger 'blur'

  $('form .member-suggest').on 'autocomplete:success', (e, entry) ->
    $variants = $(@).parent().find('.variants')
    return if $variants.find("[value=\"#{entry.id}\"]").exists()

    $entry = $(
      '<div class="variant">' +
        '<input type="hidden" name="members[]" value="'+entry.id+'" />' +
        '<a href="'+entry.url+'" class="bubbled">'+entry.name+'</a>' +
        '<span class="b-bracket-actions"><span class="item-delete">удалить</span></span>' +
      '</div>')
      .appendTo($variants)
      .process()

    @value = ''
    update_members_count()

  # пересчёт числа аниме
  update_members_count = ->
    members_count = $('#members_').next().find('a').length
    $('.members_count').html members_count
    $('.members_count_label').html p(members_count, 'участник', 'участника', 'участников')
