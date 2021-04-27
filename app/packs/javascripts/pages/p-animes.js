pageLoad('.animes', '.mangas', '.ranobe', async () => {
  if ($('.b-animes-menu').exists()) {
    const { AnimesMenu } =
      await import(/* webpackChunkName: "db_entries_menu" */ 'views/db_entries/menu');
    new AnimesMenu('.b-animes-menu')
  }
});
