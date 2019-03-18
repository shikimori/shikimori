pageLoad 'tests_vue', ->
  require.ensure [], ->
    Vue = require('vue/instance').Vue
    Test1 = require('vue/components/tests/test_1.vue').default

    new Vue
      el: '#vue_app'
      render: (h) -> h(Test1)
