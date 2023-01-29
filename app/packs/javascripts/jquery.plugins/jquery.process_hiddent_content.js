$.fn.extend({
  process_hidden_content() {
    return this.each(async function() {
      const $content = $(this);

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
