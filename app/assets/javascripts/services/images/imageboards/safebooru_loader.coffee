require './loader_base'

using 'Images.Imageboard'
class Images.Imageboard.SafebooruLoader extends Images.Imageboard.LoaderBase
  _initialize: ->
    @name = 'Safebooru'
    @base_url = 'http://safebooru.org'
    @yql_format = 'XML'

  # private methods
  _images_source_url: ->
    "#{@base_url}/index.php" +
      "?page=dapi&s=post&q=index&pid=#{@page - 1}&limit=#{@limit}&tags=#{@tags}"

  _parse: (xhr_data) ->
    xhr_data?.posts?.post || []

  _image_url: (image_url, filename) ->
    image_url

  _preview_url: (preview_url, filename) ->
    preview_url
