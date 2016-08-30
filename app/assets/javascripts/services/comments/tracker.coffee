using 'Comments'
class Comments.Tracker
  @track: (JS_EXPORTS, $root) ->
    return if Object.isEmpty(JS_EXPORTS?.comments)

    JS_EXPORTS.comments.each (comment) ->
      new Comments.TrackComment comment, $root

    JS_EXPORTS.comments = null
