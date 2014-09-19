@on 'page:load', 'contests_edit', ->
  suggest_placeholder = if $('.edit.contest .member-suggest').data('member_type') == 'anime'
    'Название аниме...'
  else
    'Имя персонажа...'

  $('.edit.contest .member-suggest').make_completable suggest_placeholder
  $('.edit .proposing .hidden').removeClass 'hidden'

  # удаление элемента из опроса
  $('form').on 'click', '.item-delete', ->
    $(@).closest('li').remove()
    update_members_count()

  $('form .proposing .take').on 'click', ->
    $(@).parent().hide()
    $('.member-suggest').trigger 'autocomplete:success', [$(@).data('id'), $(@).data('text')]
    $('.member-suggest').trigger 'blur'


  $('form .member-suggest').on 'autocomplete:success', (e, id, text, label) ->
    return if !id || !text

    if $(@).hasClass('member-suggest')
      url = "/#{$(@).data('member_type')}s/"+id
      bubbled = true

    $container = $(@).next().next().children('.members_container')
    return if $container.find('[value="'+id+'"]').length

    $container.append(
      '<li>' +
        '<input type="hidden" name="members[]" value="'+id+'" />' +
        '<a href="'+url+'" ' +
          (if bubbled then 'class="bubbled"' else '') +
          '>'+text+'</a>' +
        '<span class="b-bracket-actions"><span class="item-delete">удалить</span></span>' +
      '</li>'
    )
    process_current_dom() if bubbled
    $(@).attr value: ''
    update_members_count()

  # пересчёт числа аниме
  update_members_count = ->
    members_count = $('#members_').next().find('a').length
    $('.members_count').html members_count
    $('.members_count_label').html p(members_count, 'участник', 'участника', 'участников')
