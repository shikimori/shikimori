import PreloadedGallery from './preloaded_gallery';

// dynamic loader for images from imageboards (danbooru, oreno.imouto, konachan, safebooru)
export default class ImageboardGallery extends PreloadedGallery {
  initialize() {
    super.initialize();
    this.rel = 'imageboards';
  }

  async _buildLoader() {
    const { ImageboardsLoader } = await import('services/images/imageboards_loader');
    const tag = encodeURIComponent(this.$root.data('imageboard_tag') || '').trim();

    if (tag) {
      this.loader = new ImageboardsLoader(ImageboardGallery.BATCH_SIZE, tag);
    }
  }
}
