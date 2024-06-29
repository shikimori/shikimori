import $with from '@/utils/with';
import Poll from '@/views/polls/view';

export default class TrackPoll {
  constructor(poll, $root) {
    $with(this._selector(poll), $root)
      .slice(0, 5) // process the same poll only limited amount of times
      .data('model', poll)
      .each((_, node) => new Poll(node, poll));
  }

  _selector(poll) {
    return `.poll-placeholder#${poll.id}`;
  }
}
