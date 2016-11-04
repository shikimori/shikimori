#= require ./loader_base
using 'Images.Imageboard'
class Images.Imageboard.DanbooruLoader extends Images.Imageboard.LoaderBase
  _initialize: ->
    @name = 'Danbooru'
    @base_url = 'http://danbooru.donmai.us'
    @yql_format = 'JSON'

  # private methods
  _parse: (xhr_data) ->
    xhr_data?.json || []

  _build_images: (xhr_images) ->
    xhr_images.each (image) =>
      image.file_url = @base_url + image.file_url
      image.preview_url = @base_url + image.preview_url

    super xhr_images
