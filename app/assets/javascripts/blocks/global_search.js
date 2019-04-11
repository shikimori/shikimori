import Search from 'views/search/view';

$(document).on('turbolinks:load', () => {
  const $search = $('.l-top_menu-v2 .global-search');

  if ($search.length) {
    new Search($search);
  }
});
