import { Schema } from 'prosemirror-model';

const nodes = {
  doc: {
    content: 'paragraph+',
    toDOM: () => ['article', 0]
  },
  text: {
    group: 'inline'
  },
  paragraph: {
    content: 'inline*',
    group: 'block',
    parseDOM: [{ tag: 'p' }],
    toDOM: () => ['p', 0]
  }
};
const marks = {
  em: {
    parseDOM: [{ tag: 'em' }, { tag: 'i' }, { style: 'font-style=italic' }],
    toDOM: () => ['em', 0]
  },
  strong: {
    parseDOM: [{ tag: 'strong' }, { tag: 'b' }],
    toDOM: () => ['strong', 0]
  }
};
export const schema = new Schema({ nodes, marks });
