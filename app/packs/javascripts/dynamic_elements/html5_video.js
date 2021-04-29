import delay from 'delay';
import loadImage from 'image-promise';

import View from '@/views/application/view';

export default class Html5Video extends View {
  initialize() {
    this.$node.magnificPopup({
      preloader: false,
      type: 'webm',
      mainClass: 'mfp-no-margins mfp-img-mobile',
      closeOnContentClick: true
    });

    this._replaceImage();
  }

  _replaceImage(attempt = 1) {
    if (this.$node.data('video').match(/\.mp3$/)) { return; }

    const thumbnail = new Image();
    thumbnail.src = this.$node.data('src');

    loadImage(thumbnail)
      .then(() => {
        this.node.src = this.$node.data('src');
        this.node.srcset = this.$node.data('srcset');
      })
      .catch(async () => {
        if (attempt <= 60) {
          await delay(5000 * (attempt + 1));
          this._replaceImage(attempt + 1);
        }
      });
  }
}
