import TrackPoll from './track_poll'

export default class PollsTracker
  @track: (JS_EXPORTS, $root) ->
    if Object.isEmpty(JS_EXPORTS?.polls)
      return

    JS_EXPORTS.polls.forEach (poll) ->
      new TrackPoll poll, $root

    JS_EXPORTS.polls = null
