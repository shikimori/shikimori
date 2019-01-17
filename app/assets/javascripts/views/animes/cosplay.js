import View from 'views/application/view';
import ShikiGallery from 'views/application/shiki_gallery';

export default class Cosplay extends View {
  initialize() {
    this._initGalleries();
    this.on('postloader:success', () => this._initGalleries());
  }

  _initGalleries() {
    this.$('.b-gallery:not(.processed)').each(function () {
      new ShikiGallery(this);
      this.classList.add('processed');
    });
  }
}
