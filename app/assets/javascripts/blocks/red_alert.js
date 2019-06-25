import cookies from 'js-cookie';
import delay from 'delay';

$(document).on('turbolinks:load', () => {
  $('.b-hot_topics-v2.red-alert .b-close').on('click', async e => {
    const $block = $('.b-hot_topics-v2.red-alert');
    cookies.set($(e.currentTarget).data('cookie-name'), '1', { expires: 720 });
    $block.addClass('removing');

    await delay(1000);

    $block.remove();
  });
});
