pageLoad('.animes', '.mangas', '.ranobe', async () => {
  if ($('.b-animes-menu').exists()) {
    const { default: AnimesMenu } =
      await import(/* webpackChunkName: "dbentry_menu" */ 'views/animes/menu');
    new AnimesMenu('.b-animes-menu')
  }
});
