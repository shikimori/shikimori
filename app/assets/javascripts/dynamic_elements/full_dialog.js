import Topic from './topic';

export default class FullDialog extends Topic {
  // handlers
  _before_comments_clickload() {}

  // private functions
  _update_comments_loader(data) {
    if (data.postloader) {
      const $new_comments_loader = $(data.postloader).process();
      this.$comments_loader.replaceWith($new_comments_loader);
      return this.$comments_loader = $new_comments_loader;
    } else {
      this.$comments_loader.remove();
      return this.$comments_loader = null;
    }
  }
}
