require './preloaded_gallery'

using 'Images'
# динамическая загрузка картинок с борд danbooru, oreno.imouto, konachan, safebooru
class Images.ImageboardGallery extends Images.PreloadedGallery
  _after_initialize: ->
    @rel = 'imageboards'

  _build_loader: ->
    require.ensure [], (require) =>
      ImageboardsLoader = require 'services/images/imageboards_loader'

      tags = encodeURIComponent(@$root.data('tags') || '').trim()
      if tags
        @loader = new ImageboardsLoader(ImageboardGallery.BATCH_SIZE, tags)
