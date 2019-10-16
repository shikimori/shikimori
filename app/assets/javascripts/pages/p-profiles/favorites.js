import Sortable from 'sortablejs';
import Uri from 'urijs';

import axios from 'helpers/axios';

pageLoad('profiles_favorites', () => {
  const $sortable = $('.cc-favourites.sortable');
  if (!$sortable.length) {
    return;
  }

  const favoriteIds = $sortable.data('favorite_ids');
  const reorderUrlTemplate = $sortable.data('reorder_url');

  $sortable
    .children('.b-catalog_entry')
    .each((index, node) => (
      $(node).data('reorder_url', reorderUrlTemplate.replace('ID', favoriteIds[index]))
    ));

  new Sortable($sortable[0], {
    draggable: '.b-catalog_entry',
    handle: '.b-catalog_entry',
    onStart() {
      $sortable.addClass('draggable');
    },
    onEnd() {
      $sortable.removeClass('draggable');
    },
    onSort(e) {
      const reorderUrl = $(e.item).data('reorder_url');
      axios.post(
        Uri(reorderUrl).setQuery({ new_index: e.newIndex }).toString()
      );
    }
  });
});
