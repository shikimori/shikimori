# отображение персонажа
@on 'page:load', 'characters_show', ->
  # сокращение высоты описания
  $('.text').check_height max_height: 200

  new FavouriteStar $('.c-actions .fav-add'), is_favoured

  # комментировать
  $('.c-actions .new_comment').on 'click', ->
    $editor = $('.b-form.new_comment textarea')
    $.scrollTo $editor, ->
      $editor.focus()

# арт с имиджборд
@on 'page:load', 'characters_art', ->
  new Images.ImageboardGallery '.b-gallery'

# косплей
@on 'page:load', 'characters_cosplay', ->
  $('.b-gallery').gallery()
  $('.l-content').on 'postloader:success', ->
    $('.b-gallery').gallery()
