@on 'page:load', '.seyu', ->
  # добавление в избранное
  $('.c-actions .fav-add').on 'ajax:success', ->
    $(@).hide().next().show()
  # удаление из избранного
  $('.c-actions .fav-remove').on 'ajax:success', ->
    $(@).hide().prev().show()
  # комментировать
  $('.c-actions .new_comment').on 'click', ->
    $editor = $('.b-form.new_comment textarea')
    $.scrollTo $editor, ->
      $editor.focus()
