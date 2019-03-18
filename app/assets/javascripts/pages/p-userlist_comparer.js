import { COMMON_TOOLTIP_OPTIONS } from 'helpers/tooltip_options';

pageLoad('userlist_comparer_show', () =>
  $('tr.unprocessed')
    .removeClass('unprocessed')
    .find('a.tooltipped')
    .tooltip(
      Object.add(COMMON_TOOLTIP_OPTIONS, {
        offset: [
          -95,
          10
        ],
        position: 'bottom right',
        opacity: 1
      })
    )
);
