$with = require('helpers/with').default

export default class TrackUserRate
  constructor: (user_rate, $root) ->
    $with(@_selector(user_rate), $root)
      .data(model: user_rate)

  _selector: (user_rate) ->
    ".b-user_rate.#{user_rate.target_type.toLowerCase()}-#{user_rate.target_id}"
