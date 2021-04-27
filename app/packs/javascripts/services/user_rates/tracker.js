/* global: JS_EXPORTS */
import TrackCatalogEntry from './track_catalog_entry';
import TrackUserRate from './track_user_rate';
import UpdateCatalogEntry from './update_catalog_entry';
import UpdateUserRate from './update_user_rate';

export default class UserRatesTracker {
  static track(JS_EXPORTS, $root) {
    if (Object.isEmpty(JS_EXPORTS?.user_rates)) { // eslint-disable-line camelcase
      return;
    }

    JS_EXPORTS.user_rates.catalog_entry?.forEach(userRate => (
      new TrackCatalogEntry(userRate, $root)
    ));
    JS_EXPORTS.user_rates.user_rate?.forEach(userRate => (
      new TrackUserRate(userRate, $root)
    ));

    JS_EXPORTS.user_rates = null;
  }

  static update(userRate) {
    new UpdateCatalogEntry(userRate);
    new UpdateUserRate(userRate);
  }
}
