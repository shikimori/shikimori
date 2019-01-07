LoaderBase = require './loader_base'

module.exports = class DanbooruLoader extends LoaderBase
  _initialize: ->
    @name = 'Danbooru'
    @base_url = 'http://danbooru.donmai.us'
    @yql_format = 'JSON'

  # private methods
  _build_images: (xhr_images) ->
    xhr_images.forEach (image) =>
      return unless image.file_url && image.preview_url

      image.file_url =
        if image.file_url.startsWith('http')
          image.file_url
        else
          @base_url + image.file_url

      image.preview_url =
        if image.preview_url.startsWith('http')
          image.preview_url
        else
          @base_url + image.preview_url

    super xhr_images
