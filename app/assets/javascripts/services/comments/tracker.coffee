TrackComment = require './track_comment'

module.exports = class CommentsTracker
  @track: (JS_EXPORTS, $root) ->
    if Object.isEmpty(JS_EXPORTS?.comments)
      return

    JS_EXPORTS.comments.forEach (comment) ->
      new TrackComment comment, $root

    JS_EXPORTS.comments = null
