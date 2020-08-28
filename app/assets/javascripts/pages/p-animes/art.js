pageLoad('animes_art', 'mangas_art', async () => {
  const { ImageboardGallery } = await import('views/images/imageboard_gallery');
  new ImageboardGallery('.b-gallery');
});
