import { PreloadedGallery } from './preloaded_gallery';

// dynamic loader for images from imageboards (danbooru, oreno.imouto, konachan, safebooru)
export class ImageboardsGallery extends PreloadedGallery {
  initialize() {
    super.initialize();
    this.rel = 'imageboards';
  }

  async _buildLoader() {
    const { ImageboardsLoader } =
      await import(/* webpackChunkName: "imageboards_loader" */ 'services/images/imageboards_loader');

    const tag = encodeURIComponent(this.$root.data('imageboard_tag') || '').trim();

    if (tag) {
      this.loader = new ImageboardsLoader(ImageboardsGallery.BATCH_SIZE, tag);
    }
  }
}
