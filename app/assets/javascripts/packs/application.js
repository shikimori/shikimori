import 'babel-polyfill'; // async won't work w/o it

// must be require to prevent bugs with load order
window.$ = require('jquery'); // eslint-disable-line import/newline-after-import
window.jQuery = window.$;

require('application');
require('turbolinks_load');
require('turbolinks_before_cache');
