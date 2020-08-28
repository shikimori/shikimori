pageLoad('clubs_show', async () => {
  if ($('.b-gallery').exists()) {
    const { PreloadedGallery } =
      await import(/* webpackChunkName: "galleries" */ 'views/images/preloaded_gallery');

    new PreloadedGallery('.b-gallery');
  }
});
