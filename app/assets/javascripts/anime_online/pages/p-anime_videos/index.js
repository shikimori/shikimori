import delay from 'delay';
import Turbolinks from 'turbolinks';
import { debounce } from 'throttle-debounce';

import axios from 'helpers/axios';
import flash from 'services/flash'
import ShikiHtml5Video from 'views/application/shiki_html5_video';

pageLoad('anime_videos_index', () => {
  initVideoPlayer();

  const debouncedResize = debounce(250, resizeVideoPlayer);
  debouncedResize();

  $(window).on('resize', debouncedResize);
  $(window).one('page:before-unload', () => $(window).off('resize', debouncedResize));

  // переключение вариантов видео
  $('.video-variant-switcher').on('click', switchVideoVariant);

  // select current video kind
  const $player = $('.b-video_player');
  const kind = $player.data('kind');
  const $switcher = $(`.video-variant-switcher[data-kind='${kind}']`);

  if (kind && $switcher.length) {
    $switcher.click();
  } else {
    $('.video-variant-switcher').first().click();
  }

  // выбор видео
  $('.l-page').on('ajax:before', '.b-video_variant a', () =>
    $('.player-container').addClass('b-ajax')
  );

  $('.l-page').on('ajax:success', '.b-video_variant a', (e, html) => {
    $('.player-container')
      .removeClass('b-ajax')
      .html(html);
    initVideoPlayer();

    window.history.pushState(
      { turbolinks: true, url: e.target.href },
      '',
      e.target.href
    );
  });
});

function initVideoPlayer() {
  resizeVideoPlayer();

  const $player = $('.b-video_player');
  const $video = $player.find('video');

  // html 5 video player
  if ($video.length) {
    new ShikiHtml5Video($video);
  }

  // some logic
  // highlight current episode
  const episode = $player.data('episode');
  $(`.c-anime_video_episodes .b-video_variant[data-episode='${episode}']`)
    .addClass('active')
    .siblings()
    .removeClass('active');

  // highlight current video by id
  $(`.b-video_variant.special[data-video_id='${$player.data('video_id')}']`)
    .addClass('active')
    .siblings()
    .removeClass('active');

  const videoIds = $player.data('video_ids');
  if (videoIds && videoIds.length) {
    videoIds.forEach(videoId =>
      $(`.b-video_variant:not(.special)[data-video_id='${videoId}']`)
        .addClass('active')
        .siblings()
        .removeClass('active')
    );
  }

  // инкремент числа просмотров
  incrementViewCounts($player);

  // handlers
  // показ дополнительных кнопок для видео
  $('.cc-player_controls .show-options').on('click', toggleOptions);

  // добавление в список
  $('.cc-player_controls').on('ajax:success', '.create-user_rate', function () {
    // без delay срабатывает ещё increment-user_rate handler
    return delay().then(() => {
      const $link = $(this);

      flash.notice('Аниме добавлено в список');
      $link
        .removeClass('create-user_rate')
        .addClass('increment-user_rate')
        .attr({
          href: $link.data('increment_url') });

      return $link
        .find('.label')
        .text($link.data('increment_text'));
    });
  });

  // отметка о прочтении
  $('.cc-player_controls').on('ajax:before', '.increment-user_rate', function () {
    return $(this).addClass('b-ajax');
  });

  $('.cc-player_controls').on('ajax:complete', '.increment-user_rate', function () {
    if (!$('.increment-user_rate').hasClass('watched')) {
      flash.notice('Эпизод отмечен просмотренным');
    }

    return delay(500).then(() => {
      $(this).removeClass('b-ajax');
      return Turbolinks.visit($(this).data('next_url'));
    });
  });

  // переключение номера эпизода
  $('.cc-player_controls .episode-num input')
    .on('change', function () {
      Turbolinks.visit(
        $(this).data('href').replace('EPISODE_NUMBER', this.value)
      );
    })
    .on('keydown', function (e) {
      if ((e.keyCode === 10) || (e.keyCode === 13)) {
        $(this).trigger('change');
      }
    });

  // кнопка жалобы
  $('.cc-player_controls .report').on('click', function () {
    if ($(this).hasClass('selected')) {
      hideReport();
    }
    showReport();
  });

  // отмена жалобы
  $('.cc-anime_video_report-new .cancel').on('click', hideReport);

  // сабмит жалобы
  $('.cc-anime_video_report-new form').on('ajax:success', () => {
    flash.notice(
      'Жалоба отправлена и вскоре будет рассмотрена модератором. ' +
        'Домо аригато'
    );
    hideReport();
  });

  $('.about-ads .b-close', $player).on('click', async e => {
    const $block = $('.about-ads', $player);
    $.cookie($(e.currentTarget).data('cookie-name'), '1', { expires: 60 });
    $block.addClass('removing');
    await delay(1000);
    $block.remove();
  });
}

function showReport() {
  $('.cc-player_controls').hide();
  $('.cc-anime_video_report-new').show();
}

function hideReport() {
  $('.cc-player_controls').show();
  $('.cc-anime_video_report-new').hide();
}

function toggleOptions() {
  $('.cc-player_controls .show-options').toggleClass('selected');
  $('.cc-navigation').toggle();
  $('.cc-optional_controls').toggle();
}

function resizeVideoPlayer() {
  const $player = $('iframe, object, embed, .player-placeholder', '.player-area');
  const maxHeight = parseInt($(window).height() * 0.95);
  const desiredHeight = parseInt(($player.width() * 9) / 16);

  if (desiredHeight > maxHeight) {
    $player.height(maxHeight);
    $player.width((maxHeight / 9) * 16);
  }
  $player.height(desiredHeight);
}

function switchVideoVariant(e) {
  const kind = $(e.target).data('kind');

  $('.video-variant-switcher').removeClass('active');
  $(e.target).addClass('active');

  $('.video-variant-group').removeClass('active');
  return $(`.video-variant-group[data-kind='${kind}']`).addClass('active');
}

async function incrementViewCounts($player) {
  const watchDelay = $player.data('watch-delay');
  const watchUrl = $player.data('watch-url');

  if (!watchDelay) { return; }

  const videoUrl = document.location.href;
  await delay(watchDelay);

  if (videoUrl === document.location.href) {
    axios.post(watchUrl);
  }
}
