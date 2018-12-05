uEvent = require 'uevent'

module.exports = class LoaderBase
  FETCH_EVENT: 'loader:fetch'

  constructor: (@tags, @forbidden_tags) ->
    uEvent.mixin @

    @page = 1
    @limit = 100
    @is_finished = false
    @is_loading = false
    @camo_base_url =
      if window.ENV == 'development'
        'https://camo-v2.shikimori.org'
      else
        window.CAMO_URL

    @_initialize()

  # public methods
  fetch: (callback) ->
    @is_loading = true
    $["yql#{@yql_format}"](@_images_source_url(), @_fetch_success, @_fetch_fail)

  # handlers
  _fetch_success: (data) =>
    images = @_xhr_to_images(@_parse(data))
    @page += 1
    @is_loading = false

    console.log @name, "fetched: #{images.length}", "is_finished: #{@is_finished}"

    @trigger @FETCH_EVENT, images

  _fetch_fail: =>
    @is_loading = false
    console.warn 'fetch failure'

  # private methods
  _xhr_to_images: (xhr_images) ->
    images = @_build_images(xhr_images)
    @is_finished = true if images.length != @limit
    @_censor(images).reverse()

  _build_images: (xhr_images) ->
    xhr_images = [xhr_images] if Object.isObject(xhr_images)
    xhr_images
      .exclude (image) => !image.file_url || !image.preview_url
      .map (image) =>
        extension = '.' + image.file_url.replace(/.*\./, '')
        filename = [
          @tags,
          "#{image.width}x#{image.height}",
          image.author,
          image.id
        ].join('_').replace(/^_/, '').replace(/ /g, '__').replace(/$/, extension)
        image_url = @_image_url image.file_url, filename
        preview_url = @_preview_url image.preview_url, filename

        id: image.id
        md5: image.md5
        tags: image.tags
        rating: image.rating
        original_url: image_url
        preview_url: preview_url

  _censor: (images) ->
    return images unless @forbidden_tags

    images.filter (image) =>
      !(@forbidden_tags.test(image.tags) || image.rating == 'e')

  _images_source_url: ->
    "#{@base_url}/post/index.json?page=#{@page}&limit=#{@limit}&tags=#{@tags}"

  _camo_url: (image_url, filename) ->
    @camo_base_url + "?filename=#{filename}&url=#{image_url}"

  _image_url: (image_url, filename) ->
    image_url = "https:#{image_url}" if image_url.match /^\/\//
    @_camo_url image_url, filename

  _preview_url: (preview_url, filename) ->
    preview_url = "https:#{preview_url}" if preview_url.match /^\/\//
    @_camo_url preview_url, filename
