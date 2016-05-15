@on 'page:load', 'seyu_show', ->
  new FavouriteStar $('.c-actions .fav-add'), is_vafoured

  # комментировать
  $('.c-actions .new_comment').on 'click', ->
    $editor = $('.b-form.new_comment textarea')
    $.scrollTo $editor, ->
      $editor.focus()
