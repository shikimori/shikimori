using 'UserRates'
class UserRates.TrackCatalogEntry
  MARK = 'not-tracked'

  constructor: (user_rate, $root) ->
    $root.find(".#{MARK}#{@_selector user_rate}")
      .data(user_rate: user_rate)
      .addClass(user_rate.status)
      .removeClass(MARK)

  _selector: (user_rate) ->
    ".c-#{user_rate.target_type.toLowerCase()}.entry-#{user_rate.target_id}"
