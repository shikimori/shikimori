#= require ./preloaded_gallery

using 'Images'
# динамическая загрузка картинок с борд danbooru, oreno.imouto, konachan, safebooru
class Images.ImageboardGallery extends Images.PreloadedGallery
  _after_initialize: ->
    @rel = 'imageboards'

  _build_loader: ->
    tags = encodeURIComponent(@$root.data('tags') || '').trim()
    if tags
      new Images.ImageboardsLoader(Images.ImageboardGallery.BATCH_SIZE, tags)
