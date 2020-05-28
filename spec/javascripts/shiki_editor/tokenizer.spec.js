import { expect } from 'chai';
import { Tokenizer } from 'views/shiki_editor/markdown/tokenizer';

describe('Tokenizer', () => {
  it('empty text', () => {
    expect(Tokenizer.parse(' ')).to.eql([]);
  });
});
