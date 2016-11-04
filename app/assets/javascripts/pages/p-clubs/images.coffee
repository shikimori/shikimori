@on 'page:load', 'clubs_images', ->
  new Images.PreloadedGallery '.b-gallery'
