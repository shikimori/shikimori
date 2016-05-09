#= require './track_user_rate'

using 'UserRates'
class UserRates.UpdateUserRate extends UserRates.TrackUserRate
  constructor: (user_rate, $root) ->
    $(@_selector(user_rate)).each ->
      $(@).view().update user_rate
