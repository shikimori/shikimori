@on 'page:load', '.characters', ->
  # сокращение высоты описания
  $('.text').check_height(200)

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

# арт с имиджборд
@on 'page:load', 'characters_art', ->
  $('.b-gallery').imageboard()

# косплей
@on 'page:load', 'characters_cosplay', ->
  $('.b-gallery').gallery()
  $('.l-content').on 'postloader:success', ->
    $('.b-gallery').gallery()
