import cookies from 'js-cookie';
import PaginatedCatalog from '@/views/animes/paginated_catalog';

pageLoad('animes_collection_index', 'recommendations_index', 'userlist_comparer_show', () => {
  if ($('.l-menu [data-dynamic=postloaded]').exists()) {
    $('.l-menu').one('postloaded:success', initCatalog);
  } else {
    initCatalog();
  }

  $('.b-search-results')
    .on('click', '.b-age_restricted .censored-rejected', ({ currentTarget }) => {
      cookies.set(
        currentTarget.getAttribute('data-cookie'),
        'true',
        { expires: 9999, path: '/' }
      );

      window.location.reload();
    });
});

pageLoad('animes_collection_index', async () => {
  $('.b-subposter-actions .new_comment').on('click', () => {
    $('.shiki_editor-selector').view().focus();
  });

  const [{ FavoriteStar }, { LangTrigger }] = await Promise.all([
    import(/* webpackChunkName: "db_entries_show" */ '@/views/db_entries/favorite_star'),
    import(/* webpackChunkName: "db_entries_show" */ '@/views/db_entries/lang_trigger')
  ]);

  new LangTrigger('.b-lang_trigger');
});

function initCatalog() {
  let baseCatalogPath = $('.b-collection-filters').data('base_path');

  if (window.location.pathname.match(/\/recommendations\//)) {
    baseCatalogPath = window.location.pathname.split('/').first(5).join('/');
  } else if (window.location.pathname.match(/\/comparer\//)) {
    baseCatalogPath = window.location.pathname.split('/').first(6).join('/');
  }

  new PaginatedCatalog(baseCatalogPath);
}

pageUnload('animes_collection_index', 'recommendations_index', 'userlist_comparer_show', () => {
  // восстановление плюсика у фильтра в актуальное состояние
  const $blockFilter = $('.block-filter.item-add');
  const $blockList = $blockFilter.siblings('.b-block_list');

  if ($blockList.find('.filter').length ===
      $blockList.find('.item-minus').length) {
    $blockFilter
      .removeClass('item-add')
      .addClass('item-minus');
  }
});
