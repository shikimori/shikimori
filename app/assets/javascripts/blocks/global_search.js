import CollectionSearch from 'views/application/collection_search';

$(document).on('turbolinks:load', () => {
  new CollectionSearch(
    '.l-top_menu-v2 .global-search',
    $('.searchable-collection')
  );
});
