TrackPoll = require './track_poll'

module.exports = class PollsTracker
  @track: (JS_EXPORTS, $root) ->
    if Object.isEmpty(JS_EXPORTS?.polls)
      return

    JS_EXPORTS.polls.forEach (poll) ->
      new TrackPoll poll, $root

    JS_EXPORTS.polls = null
