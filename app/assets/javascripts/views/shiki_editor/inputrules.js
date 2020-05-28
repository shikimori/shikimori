// https://github.com/ProseMirror/prosemirror-example-setup/blob/master/src/inputrules.js

import {
  inputRules,
  wrappingInputRule
  // textblockTypeInputRule,
  // smartQuotes,
  // emDash,
  // ellipsis
} from 'prosemirror-inputrules';

import { schema } from './schema';

export default inputRules({
  rules: [
    wrappingInputRule(/^\s*>\s$/, schema.nodes.blockquote)
  ]
});
