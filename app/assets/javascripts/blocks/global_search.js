import GlobalSearch from 'views/search/global';

$(document).on('turbolinks:load', () => {
  const $search = $('.l-top_menu-v2 .global-search');

  if ($search.length) {
    new GlobalSearch($search);
  }
});
