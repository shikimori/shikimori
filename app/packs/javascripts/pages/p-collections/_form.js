import { initTagsApp } from '../p-topics/_extended_form';

let tagsApp;

pageUnload(
  'collections_new',
  'collections_edit',
  'collections_create',
  'collections_update',
  () => {
    if (tagsApp) {
      tagsApp.$destroy();
    }
  });

pageLoad(
  'collections_new',
  'collections_edit',
  'collections_create',
  'collections_update',
  () => {
    initVueApp();
    initTagsApp('collection').then(app => tagsApp = app);

    const $coauthorSuggest = $('.coauthor-suggest');
    if ($coauthorSuggest.length) {
      $coauthorSuggest
        .completable()
        .on('autocomplete:success', (_e, entry) => {
          const $form = $('#new_collection_role');
          $form.find('#collection_role_user_id').val(entry.id);
          $form.submit();
        });
    }
  }
);

function enableSaveButtons() {
  $('[id*="submit_collection"]').removeAttr('disabled')
}

async function initVueApp() {
  if (!$('#vue_collection_links').exists()) {
    enableSaveButtons()
    return;
  }

  const { createApp } = await import(/* webpackChunkName: "vue" */ 'vue');
  const { createStore } = await import(/* webpackChunkName: "vuex" */ 'vuex');
  const { default: CollectionLinks } = await import('@/vue/components/collections/collection_links'); // eslint-disable-line max-len

  const storeSchema = await import('@/vue/stores/collection_links');

  const collection = $('#collection_form').data('collection');
  const autocompleteUrl = $('#collection_form').data('autocomplete_url');
  const maxLinks = $('#collection_form').data('max_links');

  const store = createStore(storeSchema);
  store.state.collection = collection;

  const app = createApp(CollectionLinks, { maxLinks, autocompleteUrl });
  app.use(store);
  app.config.globalProperties.I18n = I18n;
  app.mount('#vue_collection_links');

  enableSaveButtons()
}
