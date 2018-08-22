/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
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
