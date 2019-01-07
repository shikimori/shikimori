LoaderBase = require './loader_base'

module.exports = class KonachanLoader extends LoaderBase
  _initialize: ->
    @name = 'Konachan'
    @base_url = 'http://konachan.com'
