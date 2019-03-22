import CollectionSearch from 'views/application/collection_search';

let searchView = null;

$(document).on('turbolinks:load', () => {
  searchView = new CollectionSearch(
    '.l-top_menu-v2 .global-search',
    $('.b-search-results')
  );
});

$(document).on('keypress', e => {
  if (e.keyCode !== 47) { return; }

  const target = e.target || e.srcElement;
  const isIgnored = target.isContentEditable ||
    target.tagName === 'INPUT' || target.tagName === 'SELECT' || target.tagName === 'TEXTAREA';

  if (isIgnored) { return; }

  e.preventDefault();
  e.stopImmediatePropagation();
  searchView.$input.focus();
});
