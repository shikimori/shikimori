require './loader_base'

using 'Images.Imageboard'
class Images.Imageboard.KonachanLoader extends Images.Imageboard.LoaderBase
  _initialize: ->
    @name = 'Konachan'
    @base_url = 'http://konachan.com'
    @yql_format = 'JSON'

  # private methods
  _parse: (xhr_data) ->
    xhr_data?.json || []
