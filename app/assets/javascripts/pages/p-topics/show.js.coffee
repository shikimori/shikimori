@on 'page:load', 'topics_show', ->
  if $('.b-animes-menu').exists()
    init_animes_menu()

  else
    $('.b-show_more').show_more()
