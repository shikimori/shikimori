import PreloadedGallery from 'views/images/preloaded_gallery';

pageLoad('clubs_show', () => {
  if ($('.b-gallery').exists()) {
    new PreloadedGallery('.b-gallery');
  }
});
