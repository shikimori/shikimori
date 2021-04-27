import delay from 'delay';

pageLoad(
  'topics_index',
  'topics_show',
  'topics_new',
  'topics_edit',
  'topics_create',
  'topics_update',
  async () => {
    $('.reload').on('click', async ({ currentTarget }) => {
      currentTarget.classList.add('active');
      await delay(750);
      currentTarget.classList.remove('active');
    });

    if ($('.b-animes-menu').exists()) {
      const { AnimesMenu } =
        await import(/* webpackChunkName: "db_entries_menu" */ 'views/db_entries/menu');
      new AnimesMenu('.b-animes-menu')
    }
  });

pageLoad('topics_index', () => {
  const $form = $('form.edit_user_preferences');
  $form
    .on('change', 'input', () => $form.submit())
    .on('ajax:before', () => {
      $('.ajax-loading', $form).show();
      $('.reload', $form).hide();
    })
    .on('ajax:complete', () => {
      $('.ajax-loading', $form).hide();
      $('.reload', $form).show();
    });
});
