import isEmpty from 'lodash/isEmpty';

import TrackCatalogEntry from './track_catalog_entry';
import TrackUserRate from './track_user_rate';
import UpdateCatalogEntry from './update_catalog_entry';
import UpdateUserRate from './update_user_rate';

export default class UserRatesTracker {
  static track(jsExports, $root) {
    if (isEmpty(jsExports?.user_rates)) {
      return;
    }

    jsExports.user_rates.catalog_entry?.forEach(userRate => (
      new TrackCatalogEntry(userRate, $root)
    ));
    jsExports.user_rates.user_rate?.forEach(userRate => (
      new TrackUserRate(userRate, $root)
    ));

    jsExports.user_rates = null;
  }

  static update(userRate) {
    new UpdateCatalogEntry(userRate);
    new UpdateUserRate(userRate);
  }
}
