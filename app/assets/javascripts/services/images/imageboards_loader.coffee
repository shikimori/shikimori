uEvent = require 'uevent'
StaticLoader = require('./static_loader').default
SafebooruLoader = require './imageboards/safebooru_loader'
DanbooruLoader = require './imageboards/danbooru_loader'
YandereLoader = require './imageboards/yandere_loader'
KonachanLoader = require './imageboards/konachan_loader'

module.exports = class ImageboardsLoader extends StaticLoader
  # какие теги отфильтровывать
  FORBIDDEN_TAGS = [
    'comic', 'cum', 'fellatio', 'pussy', 'penis', 'sex', 'pussy_juice', 'nude',
    'nipples', 'spread_legs', 'flat_color', 'micro_bikini', 'monochrome',
    'bottomless', 'censored', 'chibi', 'meme', 'dakimakura', 'undressing',
    'lowres', 'plump', 'cameltoe', 'bandaid_on_pussy', 'bandaids_on_nipples',
    'oral', 'footjob', "erect_nipples\b.*\bpanties", "breasts\b.*\btopless",
    'crotch_zipper', 'bdsm', 'side-tie_panties', 'anal', 'masturbation',
    'panty_pull', 'loli', 'print_panties'
  ]

  LOADERS = [
    SafebooruLoader,
    DanbooruLoader,
    YandereLoader,
    KonachanLoader
  ]

  initialize: () ->
    @tag = @cache
    @cache = {}

    @forbiddenTags =
      new RegExp FORBIDDEN_TAGS.map((v) -> "\\b#{v}\\b").join('|')

    @cache = []
    @hashes = {}
    @awaitingLoad = false

    @loaders = LOADERS.map (klass) => new klass(@tag, @forbiddenTags)
    @loaders.forEach (loader) =>
      loader.on loader.FETCH_EVENT, @_loaderFetch

  # public methods
  fetch: (count) ->
    if @cache.length
      @_returnFromCache()
    else
      @awaitingLoad = true
      @_vacantLoaders().forEach (loader) -> loader.fetch()

  isFinished: ->
    @cache.length == 0 &&
      @loaders.every (loader) -> loader.is_finished

  # callbacks
  # loader returned images
  _loaderFetch: (images) =>
    images
      .filter (image) => (image.md5 not of @hashes)
      .forEach (image) =>
        @hashes[image.md5] = true
        @cache.push image

    if @awaitingLoad
      @awaitingLoad = false
      @_returnFromCache()

  # private methods
  _vacantLoaders: ->
    @loaders.filter (loader) -> !loader.is_loading && !loader.is_finished
