import isEmpty from 'lodash/isEmpty';

import TrackComment from './track_comment';

export default class CommentsTracker {
  static track(jsExports, $root) {
    if (isEmpty(jsExports != null ? jsExports.comments : undefined)) {
      return;
    }

    jsExports.comments.forEach(comment => new TrackComment(comment, $root));
    jsExports.comments = null;
  }
}
