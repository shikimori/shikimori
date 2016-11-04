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
    super(xhr_images).each (image) =>
      image.original_url = @base_url + image.original_url
      image.preview_url = @base_url + image.preview_url
