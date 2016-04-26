class @TrackUserRates
  constructor: (@user_rates, @$root) ->
    console.debug 'track_user_rates', @user_rates
    return if Object.isEmpty(@user_rates)

    unless Object.isEmpty(@user_rates.catalog_entry)
      @user_rates.catalog_entry.each (user_rate) =>
        @_track user_rate

  _track: (user_rate) ->
    console.log @_rate_selector(user_rate)
    @$root.find(@_rate_selector(user_rate)).each (index, node) =>
      $(node)
        .data 'rate-status': user_rate.status
        .addClass user_rate.status

  _rate_selector: (user_rate) ->
    ".c-#{user_rate.target_type.toLowerCase()}##{user_rate.target_id}"
