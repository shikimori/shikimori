import { toggleMark, joinBackward } from 'prosemirror-commands';
import { undo, redo } from 'prosemirror-history';
import { schema } from './schema';

export const keys = {
  'Mod-z': undo,
  'Shift-Mod-z': redo,
  Backspace: joinBackward,
  'Mod-b': toggleMark(schema.marks.strong),
  'Mod-i': toggleMark(schema.marks.em)
};
