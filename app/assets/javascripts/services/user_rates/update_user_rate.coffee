import TrackUserRate from './track_user_rate'

export default class UpdateUserRate extends TrackUserRate
  constructor: (user_rate, $root) ->
    $(@_selector(user_rate)).each ->
      $(@).view().update user_rate
