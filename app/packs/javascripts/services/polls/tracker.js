import isEmpty from 'lodash/isEmpty';

import TrackPoll from './track_poll';

export default class PollsTracker {
  static track(jsExports, $root) {
    if (isEmpty(jsExports) || isEmpty(jsExports.polls)) {
      return;
    }

    jsExports.polls
      .slice(0, 30) // the same limit is in JsExports::PollsExport
      .forEach(poll => new TrackPoll(poll, $root));
    jsExports.polls = null;
  }
}
