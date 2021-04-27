import View from '@/views/application/view';
import { bind } from 'shiki-decorators';

export class Cosplay extends View {
  initialize() {
    this._initGalleries();
    this.on('postloader:success', this._initGalleries);
  }

  @bind
  async _initGalleries() {
    const { ShikiGallery } =
      await import(/* webpackChunkName: "galleries" */ 'views/application/shiki_gallery');

    this.$('.b-gallery:not(.processed)').each(function () {
      new ShikiGallery(this);
      this.classList.add('processed');
    });
  }
}
