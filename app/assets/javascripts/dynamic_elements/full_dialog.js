import Topic from './topic';

export default class FullDialog extends Topic {
  // handlers
  _beforeCommentsClickload() {}

  // private functions
  _updateCommentsLoader(data) {
    if (data.postloader) {
      const $newCommentsLoader = $(data.postloader).process();
      this.$commentsLoader.replaceWith($newCommentsLoader);
      this.$commentsLoader = $newCommentsLoader;
    } else {
      this.$commentsLoader.remove();
      this.$commentsLoader = null;
    }
  }
}
