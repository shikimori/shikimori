require './loader_base'
Base64 = require('js-base64').Base64

using 'Images.Imageboard'
class Images.Imageboard.YandereLoader extends Images.Imageboard.LoaderBase
  _initialize: ->
    @name = 'YandeRe'
    @base_url = 'https://yande.re'
    @yql_format = 'JSON'

  # public methods
  fetch: (callback) ->
    @is_loading = true
    $.getJSON(@_shiki_load_url()).success(@_fetch_success).fail(@_fetch_fail)

  # private methods
  _shiki_load_url: ->
    "/danbooru/yandere/#{Base64.encode @_images_source_url()}"

  _parse: (xhr_data) ->
    xhr_data

  _preview_url: (preview_url, filename) ->
    preview_url
