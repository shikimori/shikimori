Base64 = require('js-base64').Base64
LoaderBase = require './loader_base'
axios = require('helpers/axios').default

module.exports = class YandereLoader extends LoaderBase
  _initialize: ->
    @name = 'YandeRe'
    @base_url = 'https://yande.re'
    @yql_format = 'JSON'

  # public methods
  fetch: (callback) ->
    @is_loading = true
    axios
      .get(@_shiki_load_url())
      .catch(@_fetch_fail)
      .then (response) => @_fetch_success response.data

  # private methods
  _shiki_load_url: ->
    "/danbooru/yandere/#{Base64.encode @_images_source_url()}"

  _parse: (xhr_data) ->
    xhr_data
