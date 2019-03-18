import PaginatedCatalog from 'views/animes/paginated_catalog';

// let paginatedCatalog = null;

page_restore('animes_collection_index', 'recommendations_index', 'userlist_comparer_show', () => {
  // восстановление плюсика у фильтра в актуальное состояние
  const $blockFilter = $('.block-filter.item-add');
  const $blockList = $blockFilter.siblings('.b-block_list');

  if ($blockList.find('.filter').length ===
      $blockList.find('.item-minus').length) {
    $blockFilter
      .removeClass('item-add')
      .addClass('item-minus');
  }

  // paginatedCatalog.bind_history()
});

pageLoad('animes_collection_index', 'recommendations_index', 'userlist_comparer_show', () => {
  if ($('.l-menu .ajax-loading').exists()) {
    $('.l-menu').one('postloaded:success', initCatalog);
  } else {
    initCatalog();
  }

  $(document).trigger('page:restore');
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
