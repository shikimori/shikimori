import TrackPoll from './track_poll';

export default class PollsTracker {
  static track(jsExports, $root) {
    if (Object.isEmpty(jsExports) || Object.isEmpty(jsExports.polls)) {
      return;
    }

    jsExports.polls.forEach(poll => new TrackPoll(poll, $root));
    jsExports.polls = null;
  }
}
