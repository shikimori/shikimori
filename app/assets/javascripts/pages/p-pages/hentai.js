pageLoad('pages_hentai', async () => {
  $('.c-screenshot').shikiImage();
  $('.delete-all').click(({ currentTarget }) => {
    if (!window.confirm('Точно?')) { return; }
    $(currentTarget).prev().find('.confirm').click();
  });
});
