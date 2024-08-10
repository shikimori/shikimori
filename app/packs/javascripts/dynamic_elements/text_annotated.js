import { isMobile } from 'shiki-utils';
import View from '@/views/application/view';

export default class TextAnnotated extends View {
  initialize() {
    this.$node.data('texts').forEach(text => this.addText(text));
  }

  addText(text) {
    const groupSelector = text.group_index == null ?
      '' :
      `.cc-collection-groups[data-index=${text.group_index}]`;

    this.$(`
      ${groupSelector}
      .b-catalog_entry.c-${text.linked_type}#${text.linked_id}
      .image-decor
    `).each((_index, node) => {
      $(node)
        .append(`<div class='text'>${text.text}</div>`)
        .children('.text')
        .on('click', e => {
          if (!isMobile()) { return; }

          e.preventDefault();
          e.stopImmediatePropagation();

          e.currentTarget.classList.toggle('is-focused');
        })
        .process();
    });
  }
}
