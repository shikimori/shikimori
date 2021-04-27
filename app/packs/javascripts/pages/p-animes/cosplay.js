pageLoad('animes_cosplay', 'mangas_cosplay', async () => {
  const { Cosplay } = await import(
    /* webpackChunkName: "animes_cosplay" */ '@/views/animes/cosplay'
  );
  new Cosplay('.l-content');
});
