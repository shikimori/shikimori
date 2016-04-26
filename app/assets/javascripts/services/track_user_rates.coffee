class @TrackUserRates
  constructor: (@user_rates, @$root) ->
    console.log 'track user rates'
    return if Object.isEmpty(@user_rates)

    @user_rates.each (user_rate) =>
      @_track user_rate

  _track: (user_rate) ->
    @$root.find(@_rate_selector(user_rate)).each (index, node) =>
      $(node)
        .data 'rate-status': user_rate.status
        .addClass user_rate.status

  _rate_selector: (user_rate) ->
    ".c-#{user_rate.target_type.toLowerCase()}##{user_rate.target_id}"
