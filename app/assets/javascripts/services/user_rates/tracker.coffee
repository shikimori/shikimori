TrackCatalogEntry = require './track_catalog_entry'
TrackUserRate = require './track_user_rate'
UpdateCatalogEntry = require './update_catalog_entry'
UpdateUserRate = require './update_user_rate'

module.exports = class UserRatesTracker
  @track: (JS_EXPORTS, $root) ->
    return if Object.isEmpty(JS_EXPORTS?.user_rates)

    JS_EXPORTS.user_rates.catalog_entry.forEach (user_rate) ->
      new TrackCatalogEntry user_rate, $root

    JS_EXPORTS.user_rates.user_rate.forEach (user_rate) ->
      new TrackUserRate user_rate, $root

    JS_EXPORTS.user_rates = null

  @update: (user_rate) ->
    new UpdateCatalogEntry user_rate
    new UpdateUserRate user_rate
