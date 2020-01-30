import moment from 'moment';
import URI from 'urijs';

pageLoad('animes_edit', () => {
  $('.increment-episode').on('click', e => {
    const defaultDate = moment(new Date()).format('MM.DD.YYYY HH:mm');
    const $node = $(e.currentTarget);
    const date = prompt($node.data('custom_confirm_text'), defaultDate);

    if (date) {
      const newUrl = URI($node.attr('href'))
        .removeQuery('aired_at')
        .addQuery({ aired_at: date })
        .toString();

      $node.attr('href', newUrl);
    } else {
      e.stopImmediatePropagation();
      e.preventDefault();
    }
  });
});
