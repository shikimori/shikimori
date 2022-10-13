let gallery = null;

pageUnload('clubs_show', async () => {
  if (gallery) {
    gallery.destroy();
    gallery = null;
  }
});

pageLoad('clubs_show', async () => {
  if ($('.b-gallery').exists()) {
    const { PreloadedGallery } =
      await import(/* webpackChunkName: "galleries" */ '@/views/images/preloaded_gallery');

    gallery = new PreloadedGallery('.b-gallery');
  }
});
