@on 'page:load', 'profiles_edit', ->
  # account page
  $('.avatar-delete span').on 'click', ->
    $(@)
      .closest('form')
      .find('.b-input.file #user_avatar')
      .replaceWith("<p class=\"avatar-delete\">[<span>сохраните настройки профиля</span>]</p><input type=\"hidden\" name=\"user[avatar]\" value=\"blank\" />")

    $(@).closest('.avatar-edit').remove()

  $('.ignore-suggest').completable_variant()
