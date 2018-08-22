const ShikiEditor = require('views/application/shiki_editor');

$.fn.extend({
  shikiEditor() {
    return this.each(function () {
      const $root = $(this);
      if (!$root.hasClass('unprocessed')) {
        return null;
      }

      return new ShikiEditor($root);
    });
  }
});
