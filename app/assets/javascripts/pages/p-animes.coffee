import AnimesMenu from 'views/animes/menu'

pageLoad '.animes', '.mangas', '.ranobe', ->
  new AnimesMenu('.b-animes-menu')
