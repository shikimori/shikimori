import delay from 'delay';
import cookies from 'js-cookie';

import UserRatesTracker from '@/services/user_rates/tracker';
import TopicsTracker from '@/services/topics/tracker';
import CommentsTracker from '@/services/comments/tracker';
import PollsTracker from '@/services/polls/tracker';
import DynamicParser from '@/dynamic_elements/_parser';

import { loadImages } from '@/helpers/load_image';

import {
  ANIME_TOOLTIP_OPTIONS,
  COMMON_TOOLTIP_OPTIONS
} from '@/helpers/tooltip_options';
import { isMobile } from 'shiki-utils';
import $with from '@/helpers/with';

$.fn.extend({
  process(JS_EXPORTS) {
    processCurrentDom(this, JS_EXPORTS);
    return this;
  }
});

async function processCurrentDom(root = document.body, JS_EXPORTS = window.JS_EXPORTS) {
  const $root = $(root);

  UserRatesTracker.track(JS_EXPORTS, $root);
  TopicsTracker.track(JS_EXPORTS, $root);
  CommentsTracker.track(JS_EXPORTS, $root);
  PollsTracker.track(JS_EXPORTS, $root);

  // video must be processed before dynamic Wall, otherwise "shrinked" class sometimes
  // is assigned too late for video inside wall (after WallVideo is initialized)
  $with('.b-video.unprocessed', $root).shikiVideo();

  new DynamicParser($with('.to-process', $root));

  $with('time', $root).livetime();

  // TODO: move all logic into DynamicParser

  // то, что должно превратиться в ссылки
  $with('.linkeable', $root)
    .changeTag('a')
    .removeClass('linkeable');

  // чёрные мелкие тултипы
  $with('.b-tooltipped.unprocessed', $root)
    .removeClass('unprocessed')
    .each(function () {
      if ((isMobile()) && !this.classList.contains('mobile')) {
        return;
      }

      const $tip = $(this);

      const gravity = (() => {
        switch ($tip.data('direction')) {
          case 'top': return 's';
          case 'bottom': return 'n';
          case 'right': return 'w';
          default: return 'e';
        }
      })();
      const size = $tip.data('tipsy-size');
      const className = size ? `tipsy-${size}` : null;

      $tip.tipsy({
        gravity,
        className,
        html: true,
        prependTo: document.body
      });
    });

  // подгружаемые тултипы
  $with('.anime-tooltip', $root)
    .tooltip(ANIME_TOOLTIP_OPTIONS)
    .removeClass('anime-tooltip')
    .addClass('anime-tooltip-processed')
    .removeAttr('title');

  $with('.bubbled', $root)
    .addClass('bubbled-processed')
    .removeClass('bubbled')
    .tooltip(Object.add(COMMON_TOOLTIP_OPTIONS, { offset: [-48, 10, -10] }));

  $with('.b-spoiler.unprocessed', $root).spoiler();

  $with('img.check-width', $root)
    .removeClass('check-width')
    .normalizeImage({ appendMarker: true });
  $with('.b-image.unprocessed', $root)
    .removeClass('unprocessed')
    .magnificRelGallery();

  $with('.b-show_more.unprocessed', $root)
    .removeClass('unprocessed')
    .showMore();

  // с задержкой делаем потому, что collapsed блоки могут быть в контенте,
  // загруженном аяксом, а process для таких случаев вызывается ещё до вставки в DOM
  const collapses = cookies.get('collapses');
  if (collapses) {
    await delay();
    // сворачиваение всех нужных блоков "свернуть"
    collapses
      .replace(/;$/, '')
      .split(';')
      .forEach(id =>
        $(`#collapse-${id}`)
          .filter(':not(.triggered)')
          .trigger('click', true)
      );
  }
}
