$with = require('helpers/with').default

module.exports = class TrackPoll
  MARK = 'not-tracked'

  constructor: (poll, $root) ->
    $with(".#{MARK}#{@_selector poll}", $root)
      .removeClass(MARK)
      .data(model: poll)
      .each (_, node) ->
        new Polls.View node, poll

  _selector: (poll) ->
    ".poll-placeholder##{poll.id}"
