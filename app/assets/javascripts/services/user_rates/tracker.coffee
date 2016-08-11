using 'UserRates'
class UserRates.Tracker
  @track: (JS_EXPORTS, $root) ->
    return if Object.isEmpty(JS_EXPORTS.user_rates)

    JS_EXPORTS.user_rates.catalog_entry.each (user_rate) ->
      new UserRates.TrackCatalogEntry user_rate, $root

    JS_EXPORTS.user_rates.user_rate.each (user_rate) ->
      new UserRates.TrackUserRate user_rate, $root

    JS_EXPORTS.user_rates = null

  @update: (user_rate) ->
    new UserRates.UpdateCatalogEntry user_rate
    new UserRates.UpdateUserRate user_rate
