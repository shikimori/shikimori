FavouriteStar = require 'views/application/favourite_star'

page_load 'seyu_show', ->
  new FavouriteStar $('.c-actions .fav-add'), is_favoured.seyu

  # комментировать
  $('.c-actions .new_comment').on 'click', ->
    $editor = $('.b-form.new_comment textarea')
    $.scrollTo $editor, ->
      $editor.focus()
