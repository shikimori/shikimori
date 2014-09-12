@on 'page:load', 'people_show', ->
  $('.b-entry-info').check_height 95, true

@on 'page:load', '.people', ->
  # нажатие кнопки Комментировать в меню
  $('.l-menu .comment').on 'click', ->
    $editor = $('.b-topic .editor-container .b-shiki_editor')
    if $editor.exists()
      $editor.focus()
    else
      $(document).one 'page:change', ->
        (-> $('.b-topic .editor-container .b-shiki_editor').focus()).delay()
      Turbolinks.visit $('.head .back').attr('href')
