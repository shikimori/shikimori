// do not remove. a lot of errors in old browsers otherwise (windows phone browser for example)
import 'core-js/stable';
import 'regenerator-runtime/runtime';
// some polyfills to support chrome 49
// import 'core-js/features/object/values';
// import 'core-js/features/object/entries';
// import 'core-js/features/array/includes';
// import 'core-js/features/string/pad-start';
// import 'core-js/features/string/pad-end';

import WebFont from 'webfontloader';

$(() => (
  setTimeout(() => (
    WebFont.load({
      google: {
        families: ['Open Sans:400,600,700']
      },
      classes: false,
      events: false
    })
  ), 50)
));

const key1 = '$';
window[key1] = require('jquery');
const key2 = 'jQuery';
window[key2] = require('jquery');

import 'magnific-popup';
import 'magnific-popup/dist/magnific-popup.css';
import 'nouislider/dist/nouislider.css';

import 'jquery-appear-original';
import 'jquery-mousewheel';

import '@/application';
import '@/turbolinks_load';
import '@/turbolinks_before_cache';
