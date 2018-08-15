export default class TrackCatalogEntry
  MARK = 'not-tracked'

  constructor: (user_rate, $root) ->
    $with(".#{MARK}#{@_selector user_rate}", $root)
      .data(model: user_rate)
      .addClass(user_rate.status)
      .removeClass(MARK)

  _selector: (user_rate) ->
    ".c-#{user_rate.target_type.toLowerCase()}.entry-#{user_rate.target_id}"
