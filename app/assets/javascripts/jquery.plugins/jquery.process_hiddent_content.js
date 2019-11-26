import { GLOBAL_SELECTOR } from 'dynamic_elements/cutted_covers';

$.fn.extend({
  process_hidden_content() {
    return this.each(function () {
      const $content = $(this);

      // хак для корректной работы галерей аниме внутри спойлеров
      $content.find('.align-posters').trigger('spoiler:opened');
      $content.find(`.${GLOBAL_SELECTOR}`).each(function () {
        const data = $(this).data(GLOBAL_SELECTOR);
        if (data) {
          data.inject_css();
        }
      });
    });
  }
});
