import CollectionSearch from 'views/application/collection_search'
import FavouriteStar from 'views/application/favourite_star'

pageLoad 'people_index', ->
  new CollectionSearch '.b-search'

pageLoad 'people_show', ->
  $('.b-entry-info').checkHeight max_height: 101, without_shade: true

  Object.keys(gon.is_favoured).forEach (role) ->
    if gon.person_role[role] || gon.is_favoured[role]
      $button = $(".c-actions .fav-add[data-kind='#{role}']")

      $button.show()
      new FavouriteStar $button, gon.is_favoured[role]

  # комментировать
  $('.c-actions .new_comment').on 'click', ->
    $editor = $('.b-form.new_comment textarea')
    $.scrollTo $editor, ->
      $editor.focus()
