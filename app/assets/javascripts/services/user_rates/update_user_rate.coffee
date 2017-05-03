TrackUserRate = require './track_user_rate'

module.exports = class UpdateUserRate extends TrackUserRate
  constructor: (user_rate, $root) ->
    $(@_selector(user_rate)).each ->
      $(@).view().update user_rate
