// do not remove. a lot of errors in old browsers otherwise (windows phone browser for example)
// import 'core-js/stable';
// import 'regenerator-runtime/runtime';

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
window[key1] = require('jquery'); // eslint-disable-line import/newline-after-import
const key2 = 'jQuery';
window[key2] = require('jquery'); // eslint-disable-line import/newline-after-import

import 'magnific-popup';
import 'magnific-popup/dist/magnific-popup.css';
import 'nouislider/dist/nouislider.css';

import 'jquery-appear-original';
import 'jquery-mousewheel';

import '@/application';
import '@/turbolinks_load';
import '@/turbolinks_before_cache';
