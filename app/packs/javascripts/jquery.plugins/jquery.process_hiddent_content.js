import * as CuttedCovers from '@/dynamic_elements/cutted_covers';

$.fn.extend({
  process_hidden_content() {
    return this.each(async function() {
      const $content = $(this);

      // хак для корректной работы галерей аниме внутри спойлеров
      $content.find(`.${CuttedCovers.GLOBAL_SELECTOR}`).each(function() {
        const data = $(this).data(CuttedCovers.DATA_KEY);
        if (data) {
          data.process();
        }
      });

      const AlignedPosters = await import(
        /* webpackChunkName: "aligned_posters" */ '@/dynamic_elements/aligned_posters'
      );

      $content.find(`.${AlignedPosters.GLOBAL_SELECTOR}`).each(function() {
        const data = $(this).data(AlignedPosters.DATA_KEY);
        if (data) {
          data.process();
        }
      });
    });
  }
});
