@on 'page:load', 'profiles_edit', ->
  # account page
  $('.avatar-delete span').on 'click', ->
    $(@)
      .closest('form')
      .find('.b-input.file #user_avatar')
      .replaceWith("<p class=\"avatar-delete\">[<span>сохраните настройки профиля</span>]</p><input type=\"hidden\" name=\"user[avatar]\" value=\"blank\" />")

    $(@).closest('.avatar-edit').remove()

  $('.ignore-suggest').completable_variant()

  # profile page
  $('.b-shiki_editor').shiki_editor()

  # styles page
  $page_background = $('#user_preferences_page_background')
  $page = $('.l-page')
  $('.range-slider')
    .data(value: $page_background.val() || 0)
    .noUiSlider
      range: [0, 12]
      start: parseFloat($('.range-slider').data('value'))
      handles: 1
      slide: ->
        #value = $(@).val()
        $page_background.val(@value)
        ceiled_value = 255 - Math.ceil(@value)
        $page.css('background-color', "rgb(#{ceiled_value},#{ceiled_value},#{ceiled_value})")

  $body = $('body')
  $body_background = $('#user_preferences_body_background')
  $('.backgrounds .samples li').on 'click', ->
    value = $(@).data('background')
    $body_background.val("url(#{value}) repeat").trigger('change')

  $body_background.on 'change', ->
    $body.css background: @value

  $('#user_preferences_page_border').on 'change', ->
    $('body').toggleClass 'bordered', $(@).prop('checked')
