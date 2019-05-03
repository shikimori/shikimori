$with = require('helpers/with').default

module.exports = class TrackPoll
  constructor: (poll, $root) ->
    $with(@_selector(poll), $root)
      .data(model: poll)
      .each (_, node) ->
        new Polls.View node, poll

  _selector: (poll) ->
    ".poll-placeholder##{poll.id}"
