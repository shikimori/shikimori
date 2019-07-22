pageLoad('tests_vue', async () => {
  const { Vue } = await import(/* webpackChunkName: "vue" */ 'vue/instance');
  const { default: Test1 } = await import('vue/components/tests/test_1.vue');

  new Vue({
    el: '#vue_app',
    render: h => h(Test1)
  });
});
