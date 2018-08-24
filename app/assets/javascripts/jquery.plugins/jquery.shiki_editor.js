import ShikiEditor from 'views/application/shiki_editor';

$.fn.extend({
  shikiEditor() {
    return this.each((_index, node) => {
      if (!node.classList.contains('unprocessed')) {
        return;
      }

      new ShikiEditor(node);
    });
  }
});
