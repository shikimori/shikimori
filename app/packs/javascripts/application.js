import Turbolinks from 'turbolinks';
Turbolinks.start();

import delay from 'delay';

const requireVendor = require.context('@/vendor', false);
requireVendor.keys().forEach(requireVendor);

import { throttle, debounce } from 'throttle-debounce';

import pageLoad from '@/utils/page_load';
window.pageLoad = pageLoad;

import pageUnload from '@/utils/page_unload';
window.pageUnload = pageUnload;

import i18n from '@/utils/i18n';
window.I18n = i18n;

import p from '@/utils/p';
window.p = p;

const requireJqueryPlugins = require.context('@/jquery.plugins', true);
requireJqueryPlugins.keys().forEach(requireJqueryPlugins);

const requirePages = require.context('@/pages', true);
requirePages.keys().forEach(requirePages);

const requireBlocks = require.context('@/blocks', true);
requireBlocks.keys().forEach(requireBlocks);

import ShikiUser from '@/models/shiki_user';

import FayeLoader from '@/services/faye_loader';
import CommentsNotifier from '@/services/comments_notifier';
import AchievementsNotifier from '@/services/achievements_notifier';

import bindings from '@/utils/bindings';

import dayjs from '@/utils/dayjs';
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

  window.I18n.locale = window.LOCALE;
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
    message: window.I18n.t('frontend.application.sure_to_leave_page')
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

  turbolinksHistoryFix();
});

$(document).on('selectionchange', _ => {
  let selection;

  if (window.getSelection) {
    selection = window.getSelection();
  } else if (document.getSelection) {
    selection = document.getSelection();
  }

  if (selection && selection.focusNode) {
    $(selection.focusNode)
      .closest('[data-selection_boundary]')
      .view()
      ?.setSelection();
  }
});

function turbolinksHistoryFix() {
  window.addEventListener('popstate', function(event) {
    this.turbolinks_location = Turbolinks.Location.wrap(window.location);
    if (
      Turbolinks.controller.location.requestURL ===
      this.turbolinks_location.requestURL
    ) {
      return;
    }
    if (event.state != null ? event.state.turbolinks : undefined) {
      return;
    }
    if (
      (this.window_turbolinks =
        window.history.state != null ?
          window.history.state.turbolinks :
          undefined)
    ) {
      return Turbolinks.controller.historyPoppedToLocationWithRestorationIdentifier(
        this.turbolinks_location,
        this.window_turbolinks.restorationIdentifier
      );
    } else {
      return Turbolinks.controller.historyPoppedToLocationWithRestorationIdentifier(
        this.turbolinks_location,
        Turbolinks.uuid()
      );
    }
  });
}
