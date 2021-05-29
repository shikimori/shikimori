import sugar from 'javascripts/vendor/sugar'; // eslint-disable-line import/newline-after-import
sugar.extend();

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
import 'nouislider/distribute/nouislider.css';

import 'jquery-appear-original';
import 'jquery-mousewheel';

// used in views/styles/edit.js
import 'codemirror/lib/codemirror.css';
import 'codemirror/theme/solarized.css';
import 'codemirror/addon/hint/show-hint.css';
import 'codemirror/addon/dialog/dialog.css';
import 'codemirror/addon/display/fullscreen.css';
import 'codemirror/addon/search/matchesonscrollbar.css';

import '@/application';
import '@/turbolinks_load';
import '@/turbolinks_before_cache';
