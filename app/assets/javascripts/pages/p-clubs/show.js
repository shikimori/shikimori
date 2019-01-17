import PreloadedGallery from 'views/images/preloaded_gallery';

page_load('clubs_show', () => {
  if ($('.b-gallery').exists()) {
    new PreloadedGallery('.b-gallery');
  }
});
