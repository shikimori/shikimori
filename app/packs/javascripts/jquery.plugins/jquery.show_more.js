$.fn.extend({
  showMore() {
    return this.each(function () {
      const $showMore = $(this);
      const $hideMore = $showMore.next().find('.hide-more');

      $showMore.on('click', () => {
        $showMore.hide();
        $hideMore.parent().show();
      });

      return $hideMore.on('click', () => {
        $showMore.show();
        $hideMore.parent().hide();
      });
    });
  }
});
