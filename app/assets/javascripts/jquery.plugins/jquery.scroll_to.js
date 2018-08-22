$.extend({
  scrollTo(marker, callback) {
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

    $('html, body').animate({ scrollTop: top }, 250, callback); // easeInOutCirc // easeOutElastic
  }
});
