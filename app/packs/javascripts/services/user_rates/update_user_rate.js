import TrackUserRate from './track_user_rate';

export default class UpdateUserRate {
  constructor(userRate) {
    $(TrackUserRate.selector(userRate)).each((_index, node) => {
      $(node).view().update(userRate)
    });
  }
}
