// import { createApp } from 'vue';

pageLoad('tests_vue', async () => {
  const { createApp } = await import(/* webpackChunkName: "vue" */ 'vue');
  // const { Vue } = await import(/* webpackChunkName: "vue" */ '@/vue/instance');
  const { default: Test1 } = await import('@/vue/components/tests/test_1.vue');

  createApp(Test1).mount('#vue_app');
});
