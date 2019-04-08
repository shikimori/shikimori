import CollectionSearch from 'views/application/collection_search';

let searchView = null;

$(document).on('turbolinks:load', () => {
  const $globalSearch = $('.l-top_menu-v2 .global-search');

  if ($globalSearch.length) {
    searchView = new CollectionSearch($globalSearch, $('.b-search-results'));
  }
});

$(document).on('turbolinks:before-cache', () => {
  searchView = null;
});

$(document).on('keypress', e => {
  if (e.keyCode !== 47) { return; }

  const target = e.target || e.srcElement;
  const isIgnored = target.isContentEditable ||
    target.tagName === 'INPUT' || target.tagName === 'SELECT' || target.tagName === 'TEXTAREA';

  if (isIgnored) { return; }

  if (searchView) {
    e.preventDefault();
    e.stopImmediatePropagation();

    searchView.$input.focus();
    searchView.$input[0].setSelectionRange(0, searchView.$input[0].value.length);
  }
});
