pageLoad('.polls', async () => {
  if (!$('#vue_poll_variants').exists()) { return; }

  const { Vue, Vuex } = await import(/* webpackChunkName: "vue" */ 'vue/instance');
  const { default: Poll } = await import('vue/components/poll');
  const { default: storeSchema } = await import('vue/stores/collection');

  const pollVariants = $('#poll_form').data('poll').variants;

  const store = new Vuex.Store(storeSchema);
  store.state.collection = pollVariants.map((pollVariant, index) =>
    ({
      key: index,
      label: pollVariant.label
    })
  );

  new Vue({
    el: '#vue_poll_variants',
    store,
    render: h => h(Poll)
  });
});
