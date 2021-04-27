import delay from 'delay';

$.extend({
  async scrollTo(marker, callback) {
    let top;

    if (typeof marker === 'number') {
      top = marker;
    } else {
      const $marker = $(marker);

      if ($marker.length) {
        top = $marker.offset().top - 10;
      } else {
        top = 0;
      }
    }

    $('html, body').animate({ scrollTop: top }, 300); // easeInOutCirc // easeOutElastic

    if (callback) {
      await delay(300);
      callback();
    }
  }
});
