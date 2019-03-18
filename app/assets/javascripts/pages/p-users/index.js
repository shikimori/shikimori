import CollectionSearch from 'views/application/collection_search';

page_load('users_index', () => {
  new CollectionSearch('.b-search');
});
