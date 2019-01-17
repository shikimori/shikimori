import URI from 'urijs'
import PreloadedGallery from './preloaded_gallery'

# dynamic loader for images from imageboards (danbooru, oreno.imouto, konachan, safebooru)
export default class ImageboardGallery extends PreloadedGallery
  _after_initialize: ->
    @rel = 'imageboards'

  _build_loader: ->
    require.ensure [], (require) =>
      ImageboardsLoader = require 'services/images/imageboards_loader'

      tag = encodeURIComponent(@$root.data('imageboard_tag') || '').trim()

      if tag
        @loader = new ImageboardsLoader(ImageboardGallery.BATCH_SIZE, tag)
