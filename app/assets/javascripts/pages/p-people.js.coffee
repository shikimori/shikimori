@on 'page:load', 'people_show', ->
  $('.b-entry-info').check_height 101, true

  Object.keys(is_vafoured).each (role) ->
    if person_role[role] || is_vafoured[role]
      $button = $(".c-actions .fav-add[data-kind='#{role}']")

      $button.show()
      new FavouriteStar $button, is_vafoured[role]

  # комментировать
  $('.c-actions .new_comment').on 'click', ->
    $editor = $('.b-form.new_comment textarea')
    $.scrollTo $editor, ->
      $editor.focus()
