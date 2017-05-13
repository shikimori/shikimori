page_load 'clubs_show', ->
  new Images.PreloadedGallery '.b-gallery' if $('.b-gallery').exists()
