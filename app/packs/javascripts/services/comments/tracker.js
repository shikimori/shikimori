import TrackComment from './track_comment';

export default class CommentsTracker {
  static track(JS_EXPORTS, $root) {
    if (Object.isEmpty(JS_EXPORTS != null ? JS_EXPORTS.comments : undefined)) {
      return;
    }

    JS_EXPORTS.comments.forEach(comment => new TrackComment(comment, $root));
    JS_EXPORTS.comments = null;
  }
}
