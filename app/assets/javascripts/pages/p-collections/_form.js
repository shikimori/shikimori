pageLoad(
  'collections_new',
  'collections_edit',
  'collections_create',
  'collections_update',
  async () => {
    $('.b-shiki_editor').shikiEditor();

    if (!$('#vue_collection_links').exists()) { return; }

    //import(/* webpackChunkName: "vue" */ 'vue/instance')

    require.ensure(
      [
        'vue/instance',
        'vue/components/collections/collection_links.vue',
        'vue/stores'
      ],
      () =>
        initApp(
          require('vue/instance').Vue,
          require('vue/components/collections/collection_links.vue').default,
          require('vue/stores').collection_links
        )
    );
  }
);

var initApp = function(Vue, CollectionLinks, store) {
  const collection = $('#collection_form').data('collection');
  const autocomplete_url = $('#collection_form').data('autocomplete_url');
  const max_links = $('#collection_form').data('max_links');

  store.state.collection = sortByGroups(collection);

  new Vue({
    el: '#vue_collection_links',
    store,
    render(h) {
      return h(CollectionLinks, {
        props: {
          max_links,
          autocomplete_url
        }
      });
    }
  });
};

// sort with preserving initial order
function sortByGroups(data) {
  data.links = [].concat.apply([], Object.values(data.links.groupBy(v => v.group)));
  return data;
}

