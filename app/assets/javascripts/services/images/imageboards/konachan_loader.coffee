LoaderBase = require './loader_base'

module.exports = class KonachanLoader extends LoaderBase
  _initialize: ->
    @name = 'Konachan'
    @base_url = 'http://konachan.com'
    @yql_format = 'JSON'

  # private methods
  _parse: (xhr_data) ->
    xhr_data?.json || []
