import CollectionSearch from 'views/application/collection_search';

$(document).on('turbolinks:load', () => {
  new CollectionSearch('.b-global-search', $('.searchable-collection'));
});
