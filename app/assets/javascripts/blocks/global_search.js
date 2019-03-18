import CollectionSearch from 'views/application/collection_search';

$(document).on('page:load', () => {
  new CollectionSearch('.b-global-search', $('.searchable-collection'));
});
