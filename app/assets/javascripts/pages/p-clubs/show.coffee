@on 'page:load', 'clubs_show', ->
  new Images.PreloadedGallery '.b-gallery'
