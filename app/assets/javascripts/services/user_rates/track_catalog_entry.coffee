using 'UserRates'
class UserRates.TrackCatalogEntry
  MARK = 'not-tracked'

  constructor: (user_rate, $root) ->
    console.log 'catalog_entry', user_rate
    $root.find(@_selector(user_rate))
      .data('rate-status': user_rate.status)
      .addClass(user_rate.status)
      .removeClass(MARK)

  _selector: (user_rate) ->
    ".#{MARK}.c-#{user_rate.target_type.toLowerCase()}##{user_rate.target_id}"
