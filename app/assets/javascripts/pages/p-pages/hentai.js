pageLoad('pages_hentai', async () => {
  $('.edit-page').on('postloader:success', process);
  process();

  $('.edit-page').on('click', '.delete-all', ({ currentTarget }) => {
    if (!window.confirm('Точно?')) { return; }
    $(currentTarget).prev().find('.confirm').click();
  });
});

function process() {
  $('.c-screenshot').shikiImage();
}
