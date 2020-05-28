import { icons, MenuItem } from 'prosemirror-menu';
import { TextSelection } from 'prosemirror-state';
import { toggleMark } from 'prosemirror-commands';
import { schema } from './schema';

const markActive = markType => state => {
  const { from, $from, to, empty } = state.selection;
  if (empty) {
    return markType.isInSet(state.storedMarks || $from.marks());
  }
  return state.doc.rangeHasMark(from, to, markType);
};

const canInsert = nodeType => state => {
  const { $from } = state.selection;
  for (let d = $from.depth; d >= 0; d--) {
    const index = $from.index(d);
    if ($from.node(d).canReplaceWith(index, index, nodeType)) {
      return true;
    }
  }
  return false;
};

const insertBlockAfter = (node, state, dispatch) => {
  const { tr } = state;
  const pos = tr.selection.$anchor.after();

  tr.insert(pos, node);
  const selection = TextSelection.near(tr.doc.resolve(pos));

  tr.setSelection(selection);
  if (dispatch) {
    dispatch(tr);
  }
};

const insertBlock = nodeType => (state, dispatch) => {
  insertBlockAfter(nodeType.createAndFill(), state, dispatch);
};

export const menu = {
  floating: true,
  content: [
    [
      new MenuItem({
        title: 'Toggle Strong',
        icon: icons.strong,
        enable: () => true,
        active: markActive(schema.marks.strong),
        run: toggleMark(schema.marks.strong)
      }),
      new MenuItem({
        title: 'Toggle Emphasis',
        icon: icons.em,
        enable: () => true,
        active: markActive(schema.marks.em),
        run: toggleMark(schema.marks.em)
      })
    ], [
      new MenuItem({
        title: 'Insert Paragraph',
        label: '¶',
        enable: canInsert(schema.nodes.paragraph),
        run: insertBlock(schema.nodes.paragraph)
      })
    ]
  ]
};
