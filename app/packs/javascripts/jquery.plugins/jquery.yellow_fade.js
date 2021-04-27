import delay from 'delay';

$.fn.extend({
  yellowFade() {
    return this.each(async function () {
      const $root = $(this);

      if ($root.hasClass('yellow-fade')) { return; }
      $root.addClass('yellow-fade');

      await delay(50);
      $root.addClass('yellow-fade-animated');

      await delay(1000);
      $root.removeClass('yellow-fade yellow-fade-animated');
    });
  }
});
