FavouriteStar = require 'views/application/favourite_star'

# отображение персонажа
page_load 'characters_show', ->
  # сокращение высоты описания
  $('.text').check_height max_height: 200

  new FavouriteStar $('.c-actions .fav-add'), gon.is_favoured

  # комментировать
  $('.c-actions .new_comment').on 'click', ->
    $editor = $('.b-form.new_comment textarea')
    $.scrollTo $editor, ->
      $editor.focus()

# арт с имиджборд
page_load 'characters_art', ->
  new Images.ImageboardGallery '.b-gallery'

# косплей
page_load 'characters_cosplay', ->
  new Animes.Cosplay '.l-content'
