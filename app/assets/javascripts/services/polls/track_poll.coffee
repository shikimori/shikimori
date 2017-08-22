module.exports = class TrackPoll
  MARK = 'not-tracked'

  constructor: (poll, $root) ->
    console.log poll, $with(".#{MARK}#{@_selector poll}", $root).toArray()
    # $with(".#{MARK}#{@_selector poll}", $root)
      # .removeClass(MARK)
      # .data(model: poll)

  _selector: (poll) ->
    ".poll-placeholder##{poll.id}"
