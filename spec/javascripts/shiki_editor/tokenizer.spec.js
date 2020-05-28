import sugar from 'vendor/sugar'; // eslint-disable-line import/newline-after-import
import { expect } from 'chai';

sugar.extend();

import { Tokenizer } from 'views/shiki_editor/markdown/tokenizer';

describe('Tokenizer', () => {
  it('empty text', () => {
    expect(Tokenizer.parse(' ')).to.eql([]);
  });

  it('a', () => {
    expect(Tokenizer.parse('a')).to.eql([{
      children: null,
      content: '',
      nesting: 1,
      tag: 'p',
      type: 'paragraph_open'
    }, {
      children: [{
        children: null,
        content: 'a',
        nesting: 0,
        tag: '',
        type: 'text'
      }],
      content: 'a',
      nesting: 0,
      tag: '',
      type: 'inline'
    }, {
      children: null,
      content: '',
      nesting: -1,
      tag: 'p',
      type: 'paragraph_close'
    }]);
  });
});
