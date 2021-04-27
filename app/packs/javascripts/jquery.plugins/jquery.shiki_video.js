const prepare = (domain, href) => (
  {
    index: `${domain}/`,
    src: '%id%',
    id(_url) { return href; }
  }
);

const hostingPatterns = url => (
  {
    youtube: prepare('youtube.com', url),
    vimeo: prepare('vimeo.com', url),
    youtu_be: prepare('youtu.be', url),
    // rutube_ru: prepare('rutube.ru', url),
    vk_com: prepare('vk.com', url),
    vkontakte_ru: prepare('vkontakte.ru', url),
    coub_com: prepare('coub.com', url),
    // twitch_tv: prepare('twitch.tv', url),
    myvi_ru: prepare('myvi.ru', url),
    myvi_tv: prepare('myvi.tv', url),
    myvi_top: prepare('myvi.top', url),
    sibnet: prepare('sibnet.ru', url),
    yandex_ru: prepare('yandex.ru', url),
    // dailymotion_com: prepare('dailymotion.com', url),
    // streamable_com: prepare('streamable.com', url),
    // smotret_anime: prepare('smotretanime.ru', url),
    ok_ru: prepare('ok.ru', url),
    // youmite_ru: prepare('youmite.ru', url),
    // viuly_io: prepare('viuly.io', url),
    stormo_xyz: prepare('stormo.xyz', url),
    stormo_tv: prepare('stormo.tv', url)
    // mediafile_online: prepare('mediafile.online', url)
  }
);

  // youtube_example:
  //   index: 'youtube.com' # String that detects type of video (in this case YouTube). Simply via url.indexOf(index).
  //   id: 'v=' # String that splits URL in a two parts, second part should be %id%
  //   Or null - full URL will be returned
  //   Or a function that should return %id%, for example:
  //   id: function(url) { return 'parsed id'; }
  //   src: '//www.youtube.com/embed/%id%?autoplay=1' # URL that will be set as a source for iframe.

$.fn.extend({
  shikiVideo() {
    return this.each(function () {
      const $root = $(this);
      if (!$root.hasClass('unprocessed')) { return; }
      $root.removeClass('unprocessed');

      const $link = $root.find('.video-link');
      // const isSpecialCoub = $root.hasClass('b-coub');

      $link.magnificPopup({
        preloader: false,
        type: 'iframe',
        iframe: {
          // HTML markup of popup, `mfp-close` will be replaced by the close button
          markup: `
            <div class='mfp-iframe-scaler'>
              <div class="mfp-close"></div>
              <iframe class="mfp-iframe" frameborder="0" allowfullscreen></iframe>
            </div>
          `,
          // markup: `
          //   <div
          //     class='mfp-iframe-scaler ${isSpecialCoub ? 'mfp-coub' : ''}'
          //     ${isSpecialCoub ? 'onclick="$.magnificPopup.instance.close()"' : ''}
          //   >
          //     <div class="mfp-close"></div>
          //     <iframe class="mfp-iframe" frameborder="0" allowfullscreen></iframe>
          //   </div>
          // `,
          // Templating object key. First part defines CSS selector, second attribute.
          // "iframe_src" means: find "iframe" and set attribute "src".
          srcAction: 'iframe_src',
          // closeOnContentClick: isSpecialCoub,
          patterns: hostingPatterns($link.data('href'))
        }
      });

      const $poster = $root.find('img');

      $poster.imagesLoaded(() => {
        if ($root.hasClass('youtube') &&
          $poster[0].naturalWidth === 120 && $poster[0].naturalHeight === 90
        ) {
          $poster[0].src = '/assets/globals/missing_video.png';
          $root.addClass('shrinked-1_3 dynamically-replaced');
          return;
        }

        const ratio = (($poster[0].naturalWidth * 1.0) / $poster[0].naturalHeight).round(1);

        // http://vk.com/video98023184_165811692
        if (ratio === 1.3) {
          $root.addClass('shrinked-1_3');
        }

        // https://video.sibnet.ru/video305613-SouL_Eater__AMW/
        if (ratio === 1.5) {
          $root.addClass('shrinked-1_5');
        }
      });
    });
  }
});
