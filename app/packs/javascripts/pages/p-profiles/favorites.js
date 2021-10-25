import TinyUri from 'tiny-uri';
import axios from '@/utils/axios';
import delay from 'delay';

pageLoad('profiles_favorites', async () => {
  const $sortable = $('.cc-favourites.sortable');
  if (!$sortable.length) { return; }

  const favoriteIds = $sortable.data('favorite_ids');
  const reorderUrlTemplate = $sortable.data('reorder_url');

  $sortable
    .children('.b-catalog_entry')
    .each((index, node) => (
      $(node).data('reorder_url', reorderUrlTemplate.replace('ID', favoriteIds[index]))
    ));

  const { default: Sortable } = await import('sortablejs');

  new Sortable($sortable[0], {
    draggable: '.b-catalog_entry',
    handle: '.b-catalog_entry',
    onStart() {
      $sortable.addClass('draggable');
    },
    onEnd() {
      $sortable.removeClass('draggable');
    },
    async onSort(e) {
      const reorderUrl = $(e.item).data('reorder_url');
      $sortable.parent().addClass('b-ajax');
      await Promise.all([
        axios.post(
          new TinyUri(reorderUrl).query.set('new_index', e.newIndex).toString()
        ),
        delay(250)
      ]);
      $sortable.parent().removeClass('b-ajax');
    }
  });
});
