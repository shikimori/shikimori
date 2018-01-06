CollectionSearch = require 'views/application/collection_search'
FavouriteStar = require 'views/application/favourite_star'

page_load 'seyu_index', ->
  new CollectionSearch '.b-collection_search'

page_load 'seyu_show', ->
  new FavouriteStar $('.c-actions .fav-add'), gon.is_favoured.seyu

  # комментировать
  $('.c-actions .new_comment').on 'click', ->
    $editor = $('.b-form.new_comment textarea')
    $.scrollTo $editor, ->
      $editor.focus()
