$.fn.extend({
  spoiler() {
    return this.each(function () {
      const $root = $(this);
      if (!$root.hasClass('unprocessed')) {
        return;
      }
      $root.removeClass('unprocessed');

      const $label = $root.children('label');
      const $content = $label.next();

      $root.on('spoiler:open', () => $label.click());

      $label.on('click', function (e) {
        if ((e.target !== $label[0]) && !$(this).closest($label).exists()) {
          return;
        }

        $label.hide();
        $content.css({ display: 'inline' });

        $content.find('.b-prgrph').each(function () {
          $content.addClass('no-cursor');
          $(this)
            .addClass('inner-prgrph')
            .removeClass('b-prgrph')
            .wrap('<div class="b-spoiler_prgrph"></div>');
        });

        // хак для корректной работы галерей аниме внутри спойлеров
        $content.find('.align-posters').trigger('spoiler:opened');
        $content.find(`.${DynamicElements.CuttedCovers.CLASS_NAME}`).each(function () {
          const data = $(this).data(DynamicElements.CuttedCovers.CLASS_NAME);
          if (data) {
            data.inject_css();
          }
        });
      });

      $content.on('click', e => {
        if ((e.target !== $content[0]) && ($(e.target).parent()[0] !== $content[0]) &&
          !$(e.target).hasClass('inner-prgrph')
        ) {
          return;
        }

        $label.css({ display: 'inline' });
        $content.hide();
      });
    });
  }
});
