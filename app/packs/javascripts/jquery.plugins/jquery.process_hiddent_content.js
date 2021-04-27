import delay from 'delay';
import { GLOBAL_SELECTOR, DATA_KEY } from 'dynamic_elements/cutted_covers';

$.fn.extend({
  process_hidden_content() {
    return this.each(async function () {
      const $content = $(this);

      // хак для корректной работы галерей аниме внутри спойлеров
      $content.find('.align-posters').trigger('spoiler:opened');
      $content.find(`.${GLOBAL_SELECTOR}`).each(function () {
        const data = $(this).data(DATA_KEY);
        if (data) {
          data.injectCss();
        }
      });
    });
  }
});
