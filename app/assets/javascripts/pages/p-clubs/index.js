import CollectionSearch from 'views/application/collection_search';

page_load('clubs_index', () => {
  new CollectionSearch('.b-search');
});
