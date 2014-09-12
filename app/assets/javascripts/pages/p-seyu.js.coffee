@on 'page:load', '.seyu', ->
  # нажатие кнопки Комментировать в меню
  $('.l-menu .comment').on 'click', ->
    $editor = $('.b-topic .editor-container .b-shiki_editor')
    if $editor.exists()
      $editor.focus()
    else
      $(document).one 'page:change', ->
        (-> $('.b-topic .editor-container .b-shiki_editor').focus()).delay()
      Turbolinks.visit $('.head .back').attr('href')
