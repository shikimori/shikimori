import TinyUri from 'tiny-uri';
import dayjs from '@/utils/dayjs';

const DATE_FORMAT = 'DD.MM.YYYY HH:mm';

pageLoad('animes_edit', () => {
  $('.increment-episode').on('click', e => {
    const defaultDate = dayjs(new Date()).format(DATE_FORMAT);
    const $node = $(e.currentTarget);
    const date = prompt($node.data('custom_confirm_text'), defaultDate);

    if (date) {
      const newUrl = new TinyUri($node.attr('href'))
        .query.set('aired_at', dayjs(date, DATE_FORMAT).toString())
        .toString();

      $node.attr('href', newUrl);
    } else {
      e.stopImmediatePropagation();
      e.preventDefault();
    }
  });
});
