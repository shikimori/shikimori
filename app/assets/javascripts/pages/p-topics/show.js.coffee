@on 'page:load', 'topics_new', 'topics_edit', 'topics_update', 'topics_show', ->
  if $('.b-animes-menu').exists()
    init_animes_menu()

  else
    $('.b-show_more').show_more()
