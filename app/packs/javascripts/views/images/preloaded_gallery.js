import delay from 'delay';
import { bind } from 'shiki-decorators';

import { ShikiGallery } from '@/views/application/shiki_gallery';
import JST from '@/utils/jst';

const TEMPLATE = 'images/image';

const APPEAR_MARKER_HTML =
  '<p class="ajax-loading vk-like b-appear_marker active" ' +
    'data-appear-top-offset="900"></p>';

const DEPLOY_INTERVAL = 100;
const APPEND_ACTION = 'appended';
const PREPEND_ACTION = 'prepended';

export class PreloadedGallery extends ShikiGallery {
  static BATCH_SIZE = 5;

  async initialize() {
    super.initialize({
      shikiUpload: this.$root.data('can_upload'),
      shikiUploadCustom: true
    });

    this.rel = this.$root.data('rel');
    this.canLoad = true;

    this.destroyUrl = this.$container.data('destroy_url');

    this.on('upload:success', this._appendUploaded);

    const { default: imagesLoaded } = await import('imagesloaded');
    this.desandroImagesLoaded = imagesLoaded;
    await this._buildLoader();

    this.loader.on(this.loader.FETCH_EVENT, (_e, loadedImages) =>
      this._imagesLoad(loadedImages)
    );

    this._appendAppearLoader();
    this._fetch();
  }

  destroy() {
    this.$node.find('.ajax-loading.vk-like.b-appear_marker').remove();
    this.$container.children(':not(.grid_sizer)').remove();
  }

  // callbacks
  // loader returned images
  _imagesLoad(images) {
    const html = images.map(image => this._imageToHtml(image));
    const $batch = $(html.join(''));

    this.desandroImagesLoaded($batch, loadedImages => this._deployBatch(loadedImages));
  }

  @bind
  async _appendUploaded(_e, image) {
    const $image = $(this._imageToHtml(image));
    await this.desandroImagesLoaded($image);

    this._deployImage($image, 0 * DEPLOY_INTERVAL, PREPEND_ACTION);
  }

  // private methods
  async _buildLoader() {
    const { StaticLoader } = await import('@/services/images/static_loader');
    const images = this.$container.data('images');

    this.loader = new StaticLoader(PreloadedGallery.BATCH_SIZE, images);
  }

  _appendAppearLoader() {
    this.$appearMarker = $(APPEAR_MARKER_HTML).insertAfter(this.$container);
    this.$appearMarker.on('appear', () => this._fetch());
  }

  _fetch() {
    if (this.canLoad) {
      this.loader.fetch();
      this._stopPostload();
    }
  }

  _startPostload() {
    this.canLoad = true;

    if (this.$appearMarker.is(':appeared')) {
      this._fetch();
    }
  }

  _stopPostload() {
    this.canLoad = false;
  }

  _imageToHtml(image) {
    return JST[TEMPLATE]({
      image,
      rel: this.rel,
      destroy_url: ((image.can_destroy ? this.destroyUrl.replace('ID', image.id) : undefined))
    });
  }

  async _deployBatch(images) {
    images.elements.forEach((imageNode, index) => {
      this._deployImage(imageNode, index * DEPLOY_INTERVAL, APPEND_ACTION);
    });

    // recheck postloader appearence after all images are deployed
    await delay((images.elements.length + 1) * DEPLOY_INTERVAL);

    if (this.loader.isFinished()) {
      this.$appearMarker.remove();
    } else {
      this._startPostload();
    }
  }
}
