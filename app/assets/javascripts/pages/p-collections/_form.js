pageLoad(
  'collections_new',
  'collections_edit',
  'collections_create',
  'collections_update',
  () => {
    initVueApp();
  }
);

// sort with preserving initial order
// function sortByGroups(data) {
//   data.links = [].concat.apply([], Object.values(data.links.groupBy(v => v.group)));
//   return data;
// }

async function initVueApp() {
  if (!$('#vue_collection_links').exists()) { return; }

  const { Vue, Vuex } = await import(/* webpackChunkName: "vue" */ 'vue/instance');
  const { default: CollectionLinks } = await import('vue/components/collections/collection_links'); // eslint-disable-line max-len
  const storeSchema = await import('vue/stores/collection_links');

  const collection = $('#collection_form').data('collection');
  const autocompleteUrl = $('#collection_form').data('autocomplete_url');
  const maxLinks = $('#collection_form').data('max_links');

  const store = new Vuex.Store(storeSchema);
  store.state.collection = collection; // sortByGroups(collection)

  new Vue({
    el: '#vue_collection_links',
    store,
    render: h => h(CollectionLinks, { props: { maxLinks, autocompleteUrl } })
  });
}
