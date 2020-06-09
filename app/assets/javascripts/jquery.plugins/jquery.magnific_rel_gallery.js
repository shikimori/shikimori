const buildGallery = function () {
  const item = this.items[this.index];
  if (item.rel && (this.items.length === 1)) {
    this.items = $(`a[rel='${item.rel}']`).toArray();
    return this.index = this.items.indexOf(item);
  }
};

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
            beforeOpen: buildGallery,
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
