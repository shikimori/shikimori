$with = require('helpers/with').default

export default class TrackCatalogEntry
  constructor: (user_rate, $root) ->
    $with(@_selector(user_rate), $root)
      .data(model: user_rate)
      .addClass(user_rate.status)

  _selector: (user_rate) ->
    ".c-#{user_rate.target_type.toLowerCase()}.entry-#{user_rate.target_id}"
