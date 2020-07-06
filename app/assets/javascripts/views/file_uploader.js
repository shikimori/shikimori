import ShikiFileUploader from 'shiki-file-uploader';
import flash from 'services/flash';

import csrf from 'helpers/csrf';
import uppyLocaleRu from 'vendor/uppy_locale_ru';

export class FileUploader extends ShikiFileUploader {
  constructor(node) {
    super({
      node,
      flash,
      uppyLocale: window.LOCALE === 'ru' ? uppyLocaleRu : undefined,
      xhrHeaders: () => csrf().headers
    });

    this.node.classList.remove('b-ajax');
    this._scheduleUnbind();
  }

  _scheduleUnbind() {
    $(document).one('turbolinks:before-cache', this.destroy);
  }
}
