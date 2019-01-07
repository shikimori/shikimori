import URI from 'urijs'

import './preloaded_gallery'

using 'Images'
# динамическая загрузка картинок с борд danbooru, oreno.imouto, konachan, safebooru
class Images.ImageboardGallery extends Images.PreloadedGallery
  _after_initialize: ->
    @rel = 'imageboards'

  _build_loader: ->
    require.ensure [], (require) =>
      ImageboardsLoader = require 'services/images/imageboards_loader'

      tag = encodeURIComponent(@$root.data('imageboard_tag') || '').trim()

      if tag
        @loader = new ImageboardsLoader(ImageboardGallery.BATCH_SIZE, tag)
