$ ->
  suggest_placeholder = if $('.edit.contest .member-suggest').data('member_type') == 'anime'
    'Название аниме...'
  else
    'Имя персонажа...'

  $('.edit.contest .member-suggest').make_completable suggest_placeholder
  $('.edit .proposing .hidden').removeClass 'hidden'

# сохранение опроса
$(document.body).on 'click', '.edit .save', ->
  $(@).parents('form').trigger 'submit'

# удаление элемента из опроса
$(document.body).on 'click', '.edit .item-delete', ->
  $(@).closest('li').remove()
  update_members_count()

$('.edit .proposing .take').on 'click', ->
  $('.edit.contest .member-suggest').trigger 'autocomplete:success', [$(@).data('id'), $(@).data('text')]
  $('.edit.contest .member-suggest').trigger 'blur'


$('.edit.contest .member-suggest').on 'autocomplete:success', (e, id, text, label) ->
  return if !id || !text

  if $(@).hasClass('member-suggest')
    url = "/#{$(@).data('member_type')}s/"+id
    bubbled = true

  $container = $(@).next().next().children('.container')
  return if $container.find('[value="'+id+'"]').length

  $container.append(
    '<li>' +
      '<input type="hidden" name="members[]" value="'+id+'" />' +
      '<a href="'+url+'" ' +
        (if bubbled then 'class="bubbled" data-remote="true"' else '') +
        '>'+text+'</a>' +
      '<span class="bracket-actions"><span class="item-delete">удалить</span></span>' +
    '</li>'
  )
  process_current_dom() if bubbled
  $(@).attr value: ''
  update_members_count()

# пересчёт числа аниме
update_members_count = ->
  $('.members-count').html $('#members_').next().find('a').length
