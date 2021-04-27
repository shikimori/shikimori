// import { isMobile, isWebkit } from 'shiki-utils';

// ссылки на camo в href содержат оригинальный url картинки,
// а в data-href проксированный url картинки
const extractUrl = item => item.src = item.el.data('href') || item.src;
// const GLOBAL_EVENTS = 'gesturestart gesturechange gestureend resize';
// 
// async function disableScroll() {
//   const { disablePageScroll } = await import('scroll-lock');
//   disablePageScroll();
// }

// async function enableScroll(e) {
//   const { enablePageScroll } = await import('scroll-lock');
//   enablePageScroll();
// 
//   $(window).off(GLOBAL_EVENTS, enableScroll);
// }

$.fn.extend({
  magnificRelGallery() {
    return this.each(function () {
      const $node = $(this);

      if (!$node.data('magnificPopup')) {
        return $node.magnificPopup({
          type: 'image',
          closeOnContentClick: true,
          // closeBtnInside: false

          // alignTop: true,
          fixedContentPos: true,
          fixedBgPos: true,
          gallery: {
            enabled: true,
            navigateByImgClick: true,
            preload: [0, 1]
          },

          callbacks: {
            beforeOpen() {
              const item = this.items[this.index];

              if (item.rel && (this.items.length === 1)) {
                this.items = $(`a[rel='${item.rel}']`).toArray();
                this.index = this.items.indexOf(item);
              }

              // if (!isMobile || isWebkit) {
              //   disableScroll();
              //   $(window).one(GLOBAL_EVENTS, enableScroll);
              // }
            },
            afterClose() {
              // if (!isMobile || isWebkit) {
              //   enableScroll();
              // }
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
