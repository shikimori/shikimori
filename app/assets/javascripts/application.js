import 'babel-polyfill';

require('vendor/sugar').extend();
require('es6-promise').polyfill();

window.$ = require('jquery'); // eslint-disable-line import/newline-after-import
window.jQuery = window.$;

import Turbolinks from 'turbolinks';
import moment from 'moment';
import delay from 'delay';

const requireVendor = require.context('vendor', true);
requireVendor.keys().forEach(requireVendor);

require('magnific-popup');
require('magnific-popup/dist/magnific-popup.css');
require('nouislider/distribute/nouislider.css');
require('pikaday/scss/pikaday.scss');

require('paste.js');

// used in views/styles/edit.coffee
require('codemirror/lib/codemirror.css');
require('codemirror/theme/solarized.css');
require('codemirror/addon/hint/show-hint.css');
require('codemirror/addon/dialog/dialog.css');
require('codemirror/addon/display/fullscreen.css');
require('codemirror/addon/search/matchesonscrollbar.css');

require('imagesloaded');

import bowser from 'bowser';
import { throttle, debounce } from 'throttle-debounce';

require('i18n/translations');
const csrf = require('helpers/csrf');

window.axios = require('axios').create({
  headers: Object.merge(csrf().headers, { 'X-Requested-With': 'XMLHttpRequest' })
});

window.View = require('views/application/view');
window.ShikiView = require('views/application/shiki_view');
window.ShikiEditable = require('views/application/shiki_editable');

import ShikiUser from 'models/shiki_user';

const requireHelpers = require.context('helpers', true);
requireHelpers.keys().forEach(requireHelpers);

const requireTemplates = require.context('templates', true);
window.JST = requireTemplates.keys().reduce(
  (memo, module) => {
    memo[module.replace(/^\.\/|\.\w+$/g, '')] = requireTemplates(module);
    return memo;
  },
  {}
);

const requireDynamicElements = require.context('dynamic_elements', true);
requireDynamicElements.keys().forEach(requireDynamicElements);

const requireJqueryPlugins = require.context('jquery.plugins', true);
requireJqueryPlugins.keys().forEach(requireJqueryPlugins);

const requireViews = require.context('views', true);
requireViews.keys().forEach(requireViews);

const requirePages = require.context('pages', true);
requirePages.keys().forEach(requirePages);

const requireAnimeOnlinePages = require.context('anime_online/pages', true);
requireAnimeOnlinePages.keys().forEach(requireAnimeOnlinePages);

const requireBlocks = require.context('blocks', true);
requireBlocks.keys().forEach(requireBlocks);

const MobileDetect = require('mobile-detect');

window.mobile_detect = new MobileDetect(window.navigator.userAgent);

const FayeLoader = require('services/faye_loader');
import CommentsNotifier from 'services/comments_notifier';

const bindings = require('helpers/bindings');

$(document).on(Object.keys(bindings).join(' '), e => {
  bindings[e.type].forEach(group => {
    let bodyClasses;
    if (group.conditions.length && (group.conditions[0][0] === '.')) {
      bodyClasses = group.conditions
        .filter(v => v[0] === '.')
        .map(v => `p-${v.slice(1)} `);
    } else {
      bodyClasses = [];
    }

    if (!group.conditions.length) {
      group.callback();
    } else if (bodyClasses && bodyClasses.some(v => document.body.className.indexOf(v) !== -1)) {
      group.callback();
    } else if (group.conditions.some(v => document.body.id === v)) {
      group.callback();
    }
  });
});

$(() => {
  if (!window.JS_EXPORTS) { window.JS_EXPORTS = {}; }

  const $body = $(document.body);
  window.ENV = $body.data('env');
  window.SHIKI_USER = new ShikiUser($body.data('user'));
  window.LOCALE = $body.data('locale');

  window.FAYE_URL = $body.data('faye_url');
  if (window.SHIKI_USER) { window.FAYE_CHANNEL = $body.data('faye'); }

  // if 'atatus' of window
  //   atatus
  //     .config(
  //       'e939107bae3f4735891fd79f9dee7e40',
  //       { customData: { SHIKI_USER: SHIKI_USER.id } }
  //     ).install?()

  I18n.locale = LOCALE;
  moment.locale(LOCALE);

  window.MOMENT_DIFF = moment($body.data('server_time')).diff(new Date());

  $(document).trigger('page:load', true);

  if (window.SHIKI_USER.isSignedIn && !window.SHIKI_FAYE_LOADER) {
    window.SHIKI_COMMENTS_NOTIFIER = new CommentsNotifier();
    // delay to prevent page freeze
    delay(150).then(() => window.SHIKI_FAYE_LOADER = new FayeLoader());
  }

  $('.b-appear_marker.active').appear();

  $.formNavigate({
    size: 250,
    message: I18n.t('frontend.application.sure_to_leave_page')
  });

  const match = location.hash.match(/^#(comment-\d+)$/);
  if (match) {
    $(`a[name=${match[1]}]`).closest('.b-comment').yellowFade();
  }

  // отдельные эвенты для ресайзов и скрола
  $(window).on('resize', debounce(500, () => $(document.body).trigger('resize:debounced')));
  $(window).on('scroll', throttle(750, () => $(document.body).trigger('scroll:throttled')));
});

$(document).on('page:restore', (_e, is_dom_content_loaded) => $(document.body).process());

$(document).on('page:load', (_e, is_dom_content_loaded) => {
  if (is_mobile()) {
    Turbolinks.enableProgressBar(false);
    Turbolinks.enableProgressBar(true, '.turbolinks');
  } else {
    Turbolinks.enableProgressBar(true);
  }

  document.body.classList.add(
    bowser.name.toLowerCase().replace(/ /g, '_')
  );

  // отображение flash сообщений от рельс
  $('p.flash-notice').each((k, v) => {
    if (v.innerHTML.length) { $.flash({ notice: v.innerHTML }); }
  });

  $('p.flash-alert').each((k, v) => {
    if (v.innerHTML.length) {
      $.flash({ alert: v.innerHTML });
    }
  });

  $(document.body).process();

  // переключатели видов отображения списка
  $('.b-list_switchers .switcher').on('click', function () {
    $.cookie($(this).data('name'), $(this).data('value'), { expires: 730, path: '/' });
    Turbolinks.visit(location.href);
  });
});
