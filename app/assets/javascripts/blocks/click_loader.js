import axios from 'helpers/axios';

$(document).on('click', '.click-loader', async ({ currentTarget }) => {
  const $loader = $(currentTarget);

  if ($loader.data('locked')) { return; }

  $loader.data({ locked: true });
  $loader.trigger('ajax:before');

  $loader
    .data({ html: $loader.html() })
    .html(`<div class='ajax-loading vk-like' title='${I18n.t('frontend.blocks.click_loader.loading')}' />`);

  const { data } = await axios.get($loader.data('href'));

  $loader
    .data({ locked: false })
    .trigger('ajax:success', [data]);
});
