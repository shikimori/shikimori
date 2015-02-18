@on 'page:load', 'animes_cosplay', 'mangas_cosplay', ->
  $('.b-gallery').gallery()

  $('.l-content').on 'postloader:success', ->
    $('.b-gallery').gallery()
