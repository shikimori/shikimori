import moment from 'moment';
import URI from 'urijs';

const DATE_FORMAT = 'MM.DD.YYYY HH:mm';

pageLoad('animes_edit', () => {
  $('.increment-episode').on('click', e => {
    const defaultDate = moment(new Date()).format(DATE_FORMAT);
    const $node = $(e.currentTarget);
    const date = prompt($node.data('custom_confirm_text'), defaultDate);

    if (date) {
      const newUrl = URI($node.attr('href'))
        .removeQuery('aired_at')
        .addQuery({
          aired_at: moment(date, DATE_FORMAT).toString()
        });

      $node.attr('href', newUrl);
    } else {
      e.stopImmediatePropagation();
      e.preventDefault();
    }
  });
});
