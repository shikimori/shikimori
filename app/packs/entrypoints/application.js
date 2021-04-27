// do not remove. a lot of errors in old browsers otherwise (windows phone browser for example)
require('core-js/stable');
require('regenerator-runtime/runtime');

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

import '@/application';
import '@/turbolinks_load';
import '@/turbolinks_before_cache';
