import $with from 'helpers/with';
import Poll from 'views/polls/view';

export default class TrackPoll {
  constructor(poll, $root) {
    $with(this._selector(poll), $root)
      .data('model', poll)
      .each((_, node) => new Poll(node, poll));
  }

  _selector(poll) {
    return `.poll-placeholder#${poll.id}`;
  }
}
