@on 'page:load', 'animes_art', 'mangas_art', ->
  $('.b-gallery').imageboard()

  #loader = window.loader = new GalleryManager($('.b-gallery'))
  #suggest = new ImageBoardTagsSuggest(loader)
