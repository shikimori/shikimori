$.fn.extend({
  spoiler() {
    return this.each(function() {
      const $root = $(this);
      if (!$root.hasClass('unprocessed')) {
        return;
      }
      $root.removeClass('unprocessed');

      const $label = $root.children('label');
      const $content = $label.next();

      $root.on('spoiler:open', () => $label.click());

      $label.on('click', function(e) {
        if ((e.target !== $label[0]) && !$(this).closest($label).exists()) {
          return;
        }

        $label.hide();
        $content.css({ display: 'inline' });
        $content.process_hidden_content();
      });

      if (!$content.hasClass('only-show')) {
        $content.on('click', e => {
          if ((e.target !== $content[0]) && ($(e.target).parent()[0] !== $content[0]) &&
            !$(e.target).hasClass('inner-prgrph')
          ) {
            return;
          }

          $label.css({ display: 'inline' });
          $content.hide();
        });
      }
    });
  }
});
