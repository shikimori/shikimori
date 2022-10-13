let gallery = null;

pageUnload('clubs_images', async () => {
  if (gallery) {
    gallery.destroy();
    gallery = null;
  }
});

pageLoad('clubs_images', async () => {
  const { PreloadedGallery } =
    await import(/* webpackChunkName: "galleries" */ '@/views/images/preloaded_gallery');

  gallery = new PreloadedGallery('.b-gallery');
});
