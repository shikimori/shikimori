// import { createApp } from 'vue';

pageLoad('tests_vue', async () => {
  const { createApp } = await import(/* webpackChunkName: "vue" */ 'vue');
  const { default: Test } = await import('@/vue/components/tests/test');

  createApp(Test).mount('#vue_app');
});
