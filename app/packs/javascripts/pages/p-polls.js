pageLoad('.polls', async () => {
  if (!$('#vue_poll_variants').exists()) { return; }

  const { createApp } = await import(/* webpackChunkName: "vue" */ 'vue');
  const { createStore } = await import(/* webpackChunkName: "vuex" */ 'vuex');

  const { default: ArrayField } = await import('@/vue/components/array_field');
  const { default: storeSchema } = await import('@/vue/stores/collection');

  const pollVariants = $('#poll_form').data('poll').variants;

  const store = createStore(storeSchema);
  store.state.collection = pollVariants.map((pollVariant, index) =>
    ({
      key: index,
      value: pollVariant.label
    })
  );

  const app = createApp(ArrayField, {
    resourceType: 'Poll',
    field: 'poll_variants',
    inputName: 'poll[variants_attributes][][label]',
    emptyInputName: 'poll[variants_attributes][]'
  });
  app.use(store);
  app.config.globalProperties.I18n = I18n;
  app.mount('#vue_poll_variants');
});
