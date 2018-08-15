import AnimesMenu from 'views/animes/menu'

page_load '.animes', '.mangas', '.ranobe', ->
  new AnimesMenu('.b-animes-menu')
