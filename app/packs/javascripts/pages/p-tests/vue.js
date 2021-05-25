// import { createApp } from 'vue';

pageLoad('tests_vue', async () => {
  const { createApp } = await import(/* webpackChunkName: "vue" */ 'vue');
  const { default: Test1 } = await import('@/vue/components/tests/test.vue');

  createApp(Test1).mount('#vue_app');
});
