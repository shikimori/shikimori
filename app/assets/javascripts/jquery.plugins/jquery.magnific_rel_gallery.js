// import delay from 'delay';
// ссылки на camo в href содержат оригинальный url картинки,
// а в data-href проксированный url картинки
const extractUrl = item => item.src = item.el.data('href') || item.src;

$.fn.extend({
  magnificRelGallery() {
    return this.each(function () {
      const $node = $(this);

      if (!$node.data('magnificPopup')) {
        return $node.magnificPopup({
          type: 'image',
          closeOnContentClick: true,
          // closeBtnInside: false

          gallery: {
            enabled: true,
            navigateByImgClick: true,
            preload: [0, 1]
          },

          callbacks: {
            async beforeOpen() {
              const item = this.items[this.index];

              if (item.rel && (this.items.length === 1)) {
                this.items = $(`a[rel='${item.rel}']`).toArray();
                this.index = this.items.indexOf(item);
              }
              $('.mfp-container').on('wheel', e => console.log(e));

              const { disablePageScroll } = await import('scroll-lock');
              // const { disablePageScroll, enablePageScroll } = await import('scroll-lock');
              disablePageScroll();
              // await delay(50);

              // const { zoomLevel } = await import('zoom-level');
              // $(window).on('wheel resize', e => {
              //   console.log(e)
              // });
            },
            async afterClose() {
              const { enablePageScroll } = await import('scroll-lock');
              enablePageScroll();
            },
            elementParse: extractUrl
          },

          mainClass: 'mfp-no-margins mfp-img-mobile'
          // mainClass: 'mfp-with-zoom',
          // zoom: {
          //   enabled: true,
          //   duration: 300,
          //   easing: 'ease-in-out',
          //   opener(openerElement) {
          //     if (openerElement.is('img')) { return openerElement; } else { return openerElement.find('img'); }
          //   }
          // }
        });
      }
    });
  }
});
