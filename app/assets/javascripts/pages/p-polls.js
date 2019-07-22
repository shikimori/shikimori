pageLoad('.polls', async () => {
  $('.b-shiki_editor').shikiEditor();

  if (!$('#vue_poll_variants').exists()) { return; }

  const { Vue, Vuex } = await import(/* webpackChunkName: "vue" */ 'vue/instance');
  const { default: Poll } = await import('vue/components/poll');
  const storeSchema = await import ('vue/stores/collection');

  const pollVariants = $('#poll_form').data('poll').variants;

  const store = new Vuex.Store(storeSchema);
  store.state.collection = pollVariants.map((poll_variant, index) =>
    ({
      key: index,
      label: poll_variant.label
    })
  );

  new Vue({
    el: '#vue_poll_variants',
    store,
    render: h => h(Poll)
  });
});
