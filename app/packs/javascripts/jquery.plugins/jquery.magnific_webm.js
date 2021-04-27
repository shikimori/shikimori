const NS = 'webm';

const FRAME_HTML = '<div class="mfp-figure mfp-webm-holder mfp-image-holder">' +
  '<button title="Close (Esc)" type="button" class="mfp-close">×</button>' +
  '<figure>' +
    '<div class="mfp-img">' +
      '<div class="b-fancy_loader"></div>' +
    '</div>' +
  '</figure>' +
'</div>';

$.magnificPopup.registerModule(NS, {
  options: {
    settings: null,
    cursor: 'mfp-ajax-cur'
  },

  proto: {
    initWebm() {
      return this.types.push(NS);
    },

    getWebm(item) {
      const $html = $(FRAME_HTML);
      const $videoContainer = $html.find('.mfp-img');

      const $video = $('<video>').attr({
        class: 'mfp-webm',
        src: item.el.data('video'),
        controls: 'controls',
        autoplay: true
        // preload: 'none'
      });

      import(/* webpackChunkName: "html5player" */ 'views/application/shiki_html5_video')
        .then(({ ShikiHtml5Video }) => new ShikiHtml5Video($video));

      $video.appendTo($videoContainer);

      let loaded = false;
      $video.one('loadedmetadata play playing canplay', () => {
        if (loaded) { return; }
        loaded = true;
        $html.addClass('loaded');
      });

      $video.on('error', () => {
        $videoContainer.html('<p style="color: #fff;">broken video link</p>');
      });

      this.appendContent($html);
      this.updateStatus('ready');
    }
  }
});
