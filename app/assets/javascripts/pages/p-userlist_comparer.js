import CollectionSearch from 'views/search/collection';
import { COMMON_TOOLTIP_OPTIONS } from 'helpers/tooltip_options';

pageLoad('userlist_comparer_show', () => {
  new CollectionSearch('.b-collection_search');

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
    );
});
