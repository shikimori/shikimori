pageLoad('animes_art', 'mangas_art', async () => {
  const { ImageboardGallery } =
    await import(/* webpackChunkName: "imageboard_gallery" */ 'views/images/imageboard_gallery');
  new ImageboardGallery('.b-gallery');
});
