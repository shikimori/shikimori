import delay from 'delay';
import View from '@/views/application/view';

const DEPLOY_INTERVAL = 50;

export class ShikiGallery extends View {
  initialize(customOptions) {
    const options = customOptions || {};

    this.$container = this.$('.container');

    $('.b-image', this.$container).shikiImage();

    this.$container.imagesLoaded(async () => {
      const { default: Packery } = await import('packery');

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

  async _addUpload(isShikiUploadCustom) {
    const { FileUploader } = await import('@/views/file_uploader');

    this.fileUploader = new FileUploader(this.$container[0])
      .on('upload:file:success', (_e, { response }) => {
        if (isShikiUploadCustom) {
          this.trigger('upload:success', response);
        } else {
          this._deployImage(response.html, DEPLOY_INTERVAL, 'prepended');
        }
      });
  }

  async _deployImage(imageNode, delayInterval, action) {
    const $image = $(imageNode)
      .shikiImage()
      .css({ left: -9999 })
      .prependTo(this.$container);

    await delay(delayInterval);

    // gallery can be alredy destroyed (user navigated to another page)
    if (this?.packery) {
      this.packery[action]($image[0]);
    }
  }
}
