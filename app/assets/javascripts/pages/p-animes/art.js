pageLoad('animes_art', 'mangas_art', async () => {
  const { ImageboardsGallery } =
    await import(/* webpackChunkName: "galleries" */ 'views/images/imageboards_gallery');
  new ImageboardsGallery('.b-gallery');
});
