TrackComment = require './track_comment'

module.exports = class CommentsTracker
  @track: (JS_EXPORTS, $root) ->
    return if Object.isEmpty(JS_EXPORTS?.comments)

    JS_EXPORTS.comments.forEach (comment) ->
      new TrackComment comment, $root

    JS_EXPORTS.comments = null
