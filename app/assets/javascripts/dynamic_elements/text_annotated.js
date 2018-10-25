import View from 'views/application/view';

export default class TextAnnotated extends View {
  initialize() {
    this.$node.data('texts').forEach(text => this.addText(text));
  }

  addText(text) {
    this.$(`
      .cc-collection-groups[data-index=${text.group_index}]
      .b-catalog_entry#${text.linked_id}
      .image-decor
    `).each((_index, node) =>
      $(node).append(`<div class='text'>${text.text}</div>`)
    );
  }
}
