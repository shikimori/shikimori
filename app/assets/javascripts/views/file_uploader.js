import { ShikiFileUploader } from './shiki_file_uploader';

export class FileUploader extends ShikiFileUploader {
  constructor(node) {
    super({ node });

    this.node.classList.remove('b-ajax');
    this._scheduleUnbind();
  }

  _scheduleUnbind() {
    $(document).one('turbolinks:before-cache', this.destroy);
  }
}
