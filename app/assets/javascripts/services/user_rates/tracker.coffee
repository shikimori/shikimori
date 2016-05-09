using 'UserRates'
class UserRates.Tracker
  @MARK: 'not-tracked'

  @track: (tracked_user_rates, $root) ->
    return if Object.isEmpty(tracked_user_rates)

    tracked_user_rates.catalog_entry.each (user_rate) =>
      new UserRates.TrackCatalogEntry user_rate, $root

    tracked_user_rates.user_rate.each (user_rate) =>
      new UserRates.TrackUserRate user_rate, $root

  @update: (user_rate) ->
    new UserRates.UpdateCatalogEntry user_rate
    new UserRates.UpdateUserRate user_rate
