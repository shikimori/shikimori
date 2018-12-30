import CuttedCovers from 'dynamic_elements/cutted_covers';

$.fn.extend({
  process_hidden_content() {
    return this.each(function () {
      const $content = $(this);

      // хак для корректной работы галерей аниме внутри спойлеров
      $content.find('.align-posters').trigger('spoiler:opened');
      $content.find(`.${CuttedCovers.CLASS_NAME}`).each(function () {
        const data = $(this).data(CuttedCovers.CLASS_NAME);
        if (data) {
          data.inject_css();
        }
      });
    });
  }
});
