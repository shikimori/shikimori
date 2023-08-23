/* global: JS_EXPORTS */
import TrackCatalogEntry from './track_catalog_entry';
import TrackUserRate from './track_user_rate';
import UpdateCatalogEntry from './update_catalog_entry';
import UpdateUserRate from './update_user_rate';

export default class UserRatesTracker {
  static track(js_exports, $root) {
    if (Object.isEmpty(js_exports?.user_rates)) { // eslint-disable-line camelcase
      return;
    }

    js_exports.user_rates.catalog_entry?.forEach(userRate => (
      new TrackCatalogEntry(userRate, $root)
    ));
    js_exports.user_rates.user_rate?.forEach(userRate => (
      new TrackUserRate(userRate, $root)
    ));

    js_exports.user_rates = null;
  }

  static update(userRate) {
    new UpdateCatalogEntry(userRate);
    new UpdateUserRate(userRate);
  }
}
