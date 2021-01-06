pageLoad(
  'collections_new',
  'collections_edit',
  'collections_create',
  'collections_update',
  () => {
    initVueApp();

    // $nicknameInput
    //   .completable()
    //   .on('autocomplete:success autocomplete:text', (_e, entry) => {
    //     if (entry.constructor === Object && entry.name) {
    //       $nicknameInput.val(entry.name);
    //     }
    //     $nicknameInput.closest('form').submit();
    //   })
    //   .on('keydown', e => {
    //     if (e.keyCode === 27) { // esc
    //       $('.cancel', $inviteBlock).click();
    //     }
    //   });
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
