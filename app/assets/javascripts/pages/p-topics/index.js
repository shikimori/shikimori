import AnimesMenu from 'views/animes/menu';

pageLoad(
  'topics_index',
  'topics_show',
  'topics_new',
  'topics_edit',
  'topics_create',
  'topics_update',
  () => {
    if ($('.b-animes-menu').exists()) {
      new AnimesMenu('.b-animes-menu');
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
