import { history } from 'prosemirror-history';
import { keymap } from 'prosemirror-keymap';
import { baseKeymap } from 'prosemirror-commands';
import { menuBar } from 'prosemirror-menu';
import { menu } from './menu';
import { keys } from './keys';

export const plugins = [
  history(),
  keymap(keys),
  keymap(baseKeymap),
  menuBar(menu)
];
