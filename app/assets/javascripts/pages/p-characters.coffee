import CollectionSearch from 'views/application/collection_search'
import FavouriteStar from 'views/application/favourite_star'
import ImageboardGallery from 'views/images/imageboard_gallery'

page_load 'characters_index', ->
  new CollectionSearch '.b-search'

page_load 'characters_show', ->
  $('.text').checkHeight max_height: 200

  new FavouriteStar $('.c-actions .fav-add'), gon.is_favoured

  $('.c-actions .new_comment').on 'click', ->
    $editor = $('.b-form.new_comment textarea')
    $.scrollTo $editor, ->
      $editor.focus()

page_load 'characters_art', ->
  new ImageboardGallery '.b-gallery'

page_load 'characters_cosplay', ->
  new Animes.Cosplay '.l-content'
