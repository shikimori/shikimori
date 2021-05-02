let gallery;

pageLoad('animes_art', 'mangas_art', 'ranobe_art', async () => {
  const { ImageboardsGallery } =
    await import(/* webpackChunkName: "galleries" */ '@/views/images/imageboards_gallery');
  gallery = new ImageboardsGallery('.b-gallery');
});

pageUnload('animes_art', 'mangas_art', 'ranobe_art', () => {
  gallery.destroy();
});
