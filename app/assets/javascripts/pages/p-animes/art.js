import ImageboardGallery from 'views/images/imageboard_gallery';

pageLoad('animes_art', 'mangas_art', () => {
  new ImageboardGallery('.b-gallery');
});
