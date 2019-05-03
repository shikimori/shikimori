import TrackCatalogEntry from './track_catalog_entry'
import TrackUserRate from './track_user_rate'
import UpdateCatalogEntry from './update_catalog_entry'
import UpdateUserRate from './update_user_rate'

export default class UserRatesTracker
  @track: (JS_EXPORTS, $root) ->
    JS_EXPORTS.user_rates?.catalog_entry?.forEach (user_rate) ->
      new TrackCatalogEntry user_rate, $root

    JS_EXPORTS.user_rates?.user_rate?.forEach (user_rate) ->
      new TrackUserRate user_rate, $root

    JS_EXPORTS.user_rates = null

  @update: (user_rate) ->
    new UpdateCatalogEntry user_rate
    new UpdateUserRate user_rate
