// import * as atatus from 'atatus-js'; // eslint-disable-line import/newline-after-import
// atatus
//   .config('ebe5fd3d4c754a9592b7f30f70a9c16f')
//   .install();

import Turbolinks from 'turbolinks'; // eslint-disable-line import/newline-after-import
Turbolinks.start();

import delay from 'delay';

const requireVendor = require.context('vendor', false);
requireVendor.keys().forEach(requireVendor);

import 'magnific-popup';
import 'magnific-popup/dist/magnific-popup.css';
import 'nouislider/distribute/nouislider.css';

import 'jquery-appear-original';
import 'jquery-mousewheel';

require('paste.js');
require('imagesloaded');

// used in views/styles/edit.coffee
import 'codemirror/lib/codemirror.css';
import 'codemirror/theme/solarized.css';
import 'codemirror/addon/hint/show-hint.css';
import 'codemirror/addon/dialog/dialog.css';
import 'codemirror/addon/display/fullscreen.css';
import 'codemirror/addon/search/matchesonscrollbar.css';

import { throttle, debounce } from 'throttle-debounce';

import pageLoad from 'helpers/page_load'; // eslint-disable-line import/newline-after-import
window.pageLoad = pageLoad;

import pageUnload from 'helpers/page_unload'; // eslint-disable-line import/newline-after-import
window.pageUnload = pageUnload;

const requireJqueryPlugins = require.context('jquery.plugins', true);
requireJqueryPlugins.keys().forEach(requireJqueryPlugins);

const requirePages = require.context('pages', true);
requirePages.keys().forEach(requirePages);

const requireBlocks = require.context('blocks', true);
requireBlocks.keys().forEach(requireBlocks);

import ShikiUser from 'models/shiki_user';

import FayeLoader from 'services/faye_loader';
import CommentsNotifier from 'services/comments_notifier';
import AchievementsNotifier from 'services/achievements_notifier';

import bindings from 'helpers/bindings';

import 'helpers/p';
import 'i18n/translations';

import dayjs from 'helpers/dayjs'; // eslint-disable-line import/newline-after-import
window.dayjs = dayjs;

$(document).one('turbolinks:load', () => {
  if (!window.JS_EXPORTS) { window.JS_EXPORTS = {}; }

  const $body = $(document.body);
  window.ENV = $body.data('env');
  window.SHIKI_USER = new ShikiUser($body.data('user'));
  window.LOCALE = $body.data('locale');

  window.FAYE_URL = $body.data('faye_url');
  window.CAMO_URL = $body.data('camo_url');
  if (window.SHIKI_USER) { window.FAYE_CHANNEL = $body.data('faye'); }

  // window.atatus = atatus;
  // if ('atatus' in window) {
  //   window.atatus.setUser(window.SHIKI_USER.id);
  // }

  window.I18n = I18n;
  I18n.locale = window.LOCALE;
  dayjs.locale(window.LOCALE);

  window.MOMENT_DIFF = dayjs($body.data('server_time')).diff(new Date());

  if (window.SHIKI_USER.isSignedIn && !window.SHIKI_FAYE_LOADER) {
    window.SHIKI_COMMENTS_NOTIFIER = new CommentsNotifier();
    window.SHIKI_ACHIEVEMENTS_NOTIFIER = new AchievementsNotifier();
    // delay to prevent page freeze
    delay(150).then(() =>
      window.SHIKI_FAYE_LOADER = new FayeLoader()
    );
  }

  $.appear('.b-appear_marker.active');

  $.formNavigate({
    size: 250,
    message: I18n.t('frontend.application.sure_to_leave_page')
  });

  const match = window.location.hash.match(/^#(comment-\d+)$/);
  if (match) {
    $(`a[name=${match[1]}]`).closest('.b-comment').yellowFade();
  }

  let windowWidth = window.innerWidth;
  let windowHeight = window.innerHeight;
  $(window).on('resize', debounce(500, () => {
    // additional check to prevent fake resize events on iOS
    if (windowWidth !== window.innerWidth || windowHeight !== window.innerHeigh) {
      $(document.body).trigger('resize:debounced');
      windowWidth = window.innerWidth;
      windowHeight = window.innerHeight;
    }
  }));
  $(window).on('scroll', throttle(750, () => $(document.body).trigger('scroll:throttled')));
});

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
