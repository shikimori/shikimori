FavouriteStar = require 'views/application/favourite_star'
page_load 'people_show', ->
  $('.b-entry-info').check_height max_height: 101, without_shade: true

  Object.keys(is_favoured).forEach (role) ->
    if person_role[role] || is_favoured[role]
      $button = $(".c-actions .fav-add[data-kind='#{role}']")

      $button.show()
      new FavouriteStar $button, is_favoured[role]

  # комментировать
  $('.c-actions .new_comment').on 'click', ->
    $editor = $('.b-form.new_comment textarea')
    $.scrollTo $editor, ->
      $editor.focus()
