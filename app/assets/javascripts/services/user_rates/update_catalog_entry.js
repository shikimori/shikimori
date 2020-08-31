/* eslint constructor-super:0 no-this-before-super:0 */
import TrackCatalogEntry from './track_catalog_entry';

export default class UpdateCatalogEntry extends TrackCatalogEntry {
  constructor(userRate) {
    this._selector(userRate).each((_index, node) => {
      const $node = $(node);
      const priorRate = $node.data('model');

      if (priorRate) {
        $node.removeClass(priorRate.status);
      }

      $node.data('model', userRate);

      if (userRate.id) {
        $node.addClass(userRate.status);
      }
    });
  }
}
