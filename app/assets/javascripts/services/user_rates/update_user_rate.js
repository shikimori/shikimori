/* eslint constructor-super:0 no-this-before-super:0 */
import TrackUserRate from './track_user_rate';

export default class UpdateUserRate extends TrackUserRate {
  constructor(userRate) {
    this._selector(userRate).each((_index, node) => (
      $(node).view().update(userRate)
    ));
  }
}
