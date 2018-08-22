import delay from 'delay';

import {
  ANIME_TOOLTIP_OPTIONS,
  COMMON_TOOLTIP_OPTIONS
} from 'helpers/tooltip_options';

import UserRatesTracker from 'services/user_rates/tracker';
import TopicsTracker from 'services/topics/tracker';
import CommentsTracker from 'services/comments/tracker';
import PollsTracker from 'services/polls/tracker';

$.fn.extend({
  process(JS_EXPORTS) {
    return this.each(function () {
      processCurrentDom(this, JS_EXPORTS);
    });
  }
});

// обработка элементов страницы (инициализация галерей, шрифтов, ссылок)
// TODO: переписать всю тут имеющееся на dynamic_element
async function processCurrentDom(root = document.body, JS_EXPORTS = window.JS_EXPORTS) {
  const $root = $(root);

  UserRatesTracker.track(JS_EXPORTS, $root);
  TopicsTracker.track(JS_EXPORTS, $root);
  CommentsTracker.track(JS_EXPORTS, $root);
  PollsTracker.track(JS_EXPORTS, $root);

  new DynamicElements.Parser($with('.to-process', $root));

  $with('time', $root).livetime();

  // то, что должно превратиться в ссылки
  $with('.linkeable', $root)
    .changeTag('a')
    .removeClass('linkeable');

  $with('.b-video.unprocessed', $root).shikiVideo();

  // стена картинок
  $with('.b-shiki_wall.unprocessed', $root)
    .removeClass('unprocessed')
    .each(function () {
      return new Wall.Gallery(this);
    });

  // блоки, загружаемые аяксом
  $with('.postloaded[data-href]', $root).each(function () {
    const $this = $(this);
    if (!$this.is(':visible')) {
      return;
    }

    $this.load($this.data('href'), () =>
      $this
        .removeClass('postloaded')
        .process()
        .trigger('postloaded:success')
    );

    $this.attr('data-href', null);
  });

  // чёрные мелкие тултипы
  $with('.b-tooltipped.unprocessed', $root)
    .removeClass('unprocessed')
    .each(function () {
      if ((is_mobile() || is_tablet()) && !this.classList.contains('mobile')) {
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

      $tip.tipsy({
        gravity,
        html: true,
        prependTo: document.body
      });
    });

  // подгружаемые тултипы
  $with('.anime-tooltip', $root)
    .tooltip(ANIME_TOOLTIP_OPTIONS)
    .removeClass('anime-tooltip')
    .removeAttr('title');

  $with('.bubbled', $root)
    .addClass('bubbled-processed')
    .removeClass('bubbled')
    .tooltip(Object.add(COMMON_TOOLTIP_OPTIONS, { offset: [-48, 10, -10] }));

  $with('.b-spoiler.unprocessed', $root).spoiler();

  $with('img.check-width', $root)
    .removeClass('check-width')
    .normalizeImage({ append_marker: true });
  $with('.b-image.unprocessed', $root)
    .removeClass('unprocessed')
    .magnificRelGallery();

  $with('.b-showMore.unprocessed', $root)
    .removeClass('unprocessed')
    .showMore();

  // выравнивание картинок в галерее аниме постеров
  const $posters = $with('.align-posters.unprocessed', $root);
  if ($posters.length) {
    $posters
      .removeClass('unprocessed')
      .find('img')
      .imagesLoaded(() => $posters.align_posters());
  }

  // с задержкой делаем потому, что collapsed блоки могут быть в контенте,
  // загруженном аяксом, а process для таких случаев вызывается ещё до вставки в
  // DOM
  await delay();
  // сворачиваение всех нужных блоков "свернуть"
  ($.cookie('collapses') || '')
    .replace(/;$/, '')
    .split(';')
    .forEach(id =>
      $(`#collapse-${id}`)
        .filter(':not(.triggered)')
        .trigger('click', true)
    );
};
