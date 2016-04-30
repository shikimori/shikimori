using 'UserRates'
class UserRates.TrackUserRate
  MARK = 'not-tracked'

  constructor: (user_rate, $root) ->
    console.log 'user_rate', user_rate
    $root.find(@_selector(user_rate))
      .removeClass(MARK)

  _selector: (user_rate) ->
    ".#{MARK}.b-user_rate#{user_rate.target_type.toLowerCase()}##{user_rate.target_id}"
