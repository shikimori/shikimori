using 'Images'
class Images.Loader
  @FETCH_EVENT = 'fetch'

  constructor: (@cache) ->
    uEvent.mixin @

  fetch: (count) ->
    results = @cache.splice(0, count)
    @trigger Images.Loader.FETCH_EVENT, results, @cache.length == 0
