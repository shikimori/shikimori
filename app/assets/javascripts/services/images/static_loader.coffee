uEvent = require 'uevent'

module.exports = class StaticLoader
  FETCH_EVENT: 'loader:fetch'

  constructor: (@batch_size, @cache) ->
    uEvent.mixin @

  # public methods
  fetch: ->
    @_return_from_cache()

  is_finished: ->
    @cache.length == 0

  # private methods
  _return_from_cache: ->
    @trigger @FETCH_EVENT, @cache.splice(0, @batch_size)
