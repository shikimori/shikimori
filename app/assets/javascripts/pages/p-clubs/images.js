import PreloadedGallery from 'views/images/preloaded_gallery';

pageLoad('clubs_images', () => {
  new PreloadedGallery('.b-gallery');
});
