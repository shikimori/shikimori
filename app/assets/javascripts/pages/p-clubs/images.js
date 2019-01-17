import PreloadedGallery from 'views/images/preloaded_gallery';

page_load('clubs_images', () => {
  new PreloadedGallery('.b-gallery');
});
