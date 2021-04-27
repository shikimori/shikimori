pageLoad('clubs_images', async () => {
  const { PreloadedGallery } =
    await import(/* webpackChunkName: "galleries" */ 'views/images/preloaded_gallery');

  new PreloadedGallery('.b-gallery');
});
