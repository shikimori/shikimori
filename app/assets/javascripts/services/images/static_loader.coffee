using 'Images'
class Images.StaticLoader
  @FETCH_EVENT = 'fetch'

  constructor: (@batch_size, @cache) ->
    uEvent.mixin @

  # public methods
  fetch: ->
    @_load_from_cache()

  is_finished: ->
    @cache.length == 0

  # private methods
  _return_from_cache: ->
    @trigger Images.StaticLoader.FETCH_EVENT, @cache.splice(0, @batch_size)
