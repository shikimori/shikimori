// import 'core-js/stable';
// import 'regenerator-runtime/runtime';

// must be require to prevent bugs with load order
window.$ = require('jquery'); // eslint-disable-line import/newline-after-import
window.jQuery = window.$;

require('application');
require('turbolinks_load');
require('turbolinks_before_cache');

// require('pages/p-collections/_form');

// import App from 'test.vue';
// import { Vue } from 'vue/instance';

// $(() => {
//   new Vue({
//     el: `#${document.body.id}`,
//     render: h => h(App)
//   });
// });
