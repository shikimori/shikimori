@on 'page:load', 'contests_edit', ->
  $suggest = $('.edit.contest .member-suggest')

  $('.edit .proposing .hidden').removeClass 'hidden'

  # удаление элемента из опроса
  $('form').on 'click', 'input[type=checkbox]', ->
    update_members_count()

  $('form .proposing .take').on 'click', ->
    $(@).parent().hide()
    $('.member-suggest').trigger 'autocomplete:success', [{id: $(@).data('id'), name: $(@).data('text')}]
    $('.member-suggest').trigger 'blur'

  $('.member-suggest')
    .completable_variant()
    .on 'autocomplete:success', (e, entry) ->
      update_members_count()

  # пересчёт числа аниме
  update_members_count = ->
    members_count = $('#contest_member_ids_').next().find('input:checked').length
    $('.members_count').html members_count
    $('.members_count_label').html p(members_count, 'участник', 'участника', 'участников')
