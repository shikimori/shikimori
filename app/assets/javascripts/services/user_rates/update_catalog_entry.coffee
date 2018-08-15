import TrackCatalogEntry from './track_catalog_entry'

export default class UpdateCatalogEntry extends TrackCatalogEntry
  constructor: (user_rate, $root) ->
    $(@_selector(user_rate)).each ->
      $node = $(@)
      prior_rate = $node.data('model')

      $node.removeClass prior_rate.status if prior_rate
      $node.data(model: user_rate)
      $node.addClass(user_rate.status) if user_rate.id
