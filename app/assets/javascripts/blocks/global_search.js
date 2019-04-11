import GlobalSearch from 'views/search/global';

$(document).on('turbolinks:load', () => {
  const $globalSearch = $('.l-top_menu-v2 .global-search');

  if ($globalSearch.length) {
    new GlobalSearch($globalSearch);
    // const $searchResults = $('.b-search-results');
    // searchView = new CollectionSearch($globalSearch, $searchResults);
  }
});
