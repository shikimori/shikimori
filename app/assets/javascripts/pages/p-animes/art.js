import ImageboardGallery from 'views/images/imageboard_gallery';

page_load('animes_art', 'mangas_art', () => {
  new ImageboardGallery('.b-gallery');
});
