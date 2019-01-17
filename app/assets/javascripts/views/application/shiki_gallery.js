import delay from 'delay';
import Packery from 'packery';

import View from 'views/application/view';

const DEPLOY_INTERVAL = 50;

export default class ShikiGallery extends View {
  initialize(customOptions) {
    const options = customOptions || {};

    this.$container = this.$('.container');

    $('.b-image', this.$container).shikiImage();

    this.$container.imagesLoaded(() => {
      this.packery = new Packery(this.$container[0], {
        columnWidth: '.grid_sizer',
        containerStyle: null,
        gutter: 0,
        isAnimated: false,
        isResizeBound: false,
        itemSelector: '.b-image',
        transitionDuration: options.imageboard ? 0 : '0.25s'
      });

      this.$container
        .addClass('packery')
        .data({ packery: this.packery });
    });

    if (options.shikiUpload) {
      this._addUpload(options.shikiUploadCustom);
    }
  }

  _addUpload(isShikiUploadCustom) {
    this.$container
      .shikiFile({
        progress: this.$container.prev() })

      .on('upload:success', (e, response) => {
        if (isShikiUploadCustom) { return; }
        this._deployImage(response.html, DEPLOY_INTERVAL, 'prepended');
      });
  }

  async _deployImage(imageNode, delayInterval, action) {
    const $image = $(imageNode)
      .shikiImage()
      .css({ left: -9999 })
      .prependTo(this.$container);

    await delay(delayInterval);
    this.packery[action]($image[0]);
  }
}
