export default class TrackUserRate
  MARK = 'not-tracked'

  constructor: (user_rate, $root) ->
    $with(".#{MARK}#{@_selector user_rate}", $root)
      .removeClass(MARK)
      .data(model: user_rate)

  _selector: (user_rate) ->
    ".b-user_rate.#{user_rate.target_type.toLowerCase()}-#{user_rate.target_id}"
