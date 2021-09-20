pageLoad('.animes', '.mangas', '.ranobe', async () => {
  if ($('.b-animes-menu').exists()) {
    const { AnimesMenu } =
      await import(/* webpackChunkName: "db_entries_menu" */ '@/views/db_entries/menu');
    new AnimesMenu('.b-animes-menu');
  }

  const NAVIGATION_SELECTOR = '.b-reviews_navigation .navigation-block';
  $(NAVIGATION_SELECTOR).on('click', ({ currentTarget }) => {
    if (currentTarget.classList.contains('is-active')) {
      return;
    }
    $(`${NAVIGATION_SELECTOR}.is-active`).removeClass('is-active');
    currentTarget.classList.add('is-active');

    $(`${NAVIGATION_SELECTOR}[data-ellispsis-allowed]`)
      .removeClass('is-ellipsis');

    $(`${NAVIGATION_SELECTOR}[data-ellispsis-allowed]:not(.is-active)`)
      .last()
      .addClass('is-ellipsis');
  });
});
