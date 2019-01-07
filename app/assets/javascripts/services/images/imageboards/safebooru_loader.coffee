LoaderBase = require './loader_base'

module.exports = class SafebooruLoader extends LoaderBase
  _initialize: ->
    @name = 'Safebooru'
    @base_url = 'http://safebooru.org'
    @yql_format = 'XML'

  # private methods
  _images_source_url: ->
    "#{@base_url}/index.php" +
      "?page=dapi&s=post&q=index&pid=#{@page - 1}&limit=#{@limit}&tags=#{@tags}"

  # _image_url: (image_url, filename) ->
  #   image_url

  # _preview_url: (preview_url, filename) ->
  #   preview_url
