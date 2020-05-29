import sugar from 'vendor/sugar'; // eslint-disable-line import/newline-after-import
import { expect } from 'chai';

sugar.extend();

import { Tokenizer } from 'views/shiki_editor/markdown/tokenizer';

describe('Tokenizer', () => {
  it('<empty>', () => {
    expect(Tokenizer.parse('')).to.eql([]);
  });

  describe('parahraphs', () => {
    it('z', () => {
      expect(Tokenizer.parse('z')).to.eql([{
        content: '',
        nesting: 1,
        tag: 'p',
        type: 'paragraph_open',
        children: null
      }, {
        content: 'z',
        nesting: 0,
        tag: '',
        type: 'inline',
        children: [{
          content: 'z',
          nesting: 0,
          tag: '',
          type: 'text',
          children: null
        }]
      }, {
        content: '',
        nesting: -1,
        tag: 'p',
        type: 'paragraph_close',
        children: null
      }]);
    });

    it('zzz', () => {
      expect(Tokenizer.parse('zzz')).to.eql([{
        content: '',
        nesting: 1,
        tag: 'p',
        type: 'paragraph_open',
        children: null
      }, {
        content: 'zzz',
        nesting: 0,
        tag: '',
        type: 'inline',
        children: [{
          content: 'zzz',
          nesting: 0,
          tag: '',
          type: 'text',
          children: null
        }]
      }, {
        content: '',
        nesting: -1,
        tag: 'p',
        type: 'paragraph_close',
        children: null
      }]);
    });

    it('zzz\\nxxx', () => {
      expect(Tokenizer.parse('zzz\nxxx')).to.eql([{
        content: '',
        nesting: 1,
        tag: 'p',
        type: 'paragraph_open',
        children: null
      }, {
        content: 'zzz',
        nesting: 0,
        tag: '',
        type: 'inline',
        children: [{
          content: 'zzz',
          nesting: 0,
          tag: '',
          type: 'text',
          children: null
        }]
      }, {
        content: '',
        nesting: -1,
        tag: 'p',
        type: 'paragraph_close',
        children: null
      }, {
        content: '',
        nesting: 1,
        tag: 'p',
        type: 'paragraph_open',
        children: null
      }, {
        content: 'xxx',
        nesting: 0,
        tag: '',
        type: 'inline',
        children: [{
          content: 'xxx',
          nesting: 0,
          tag: '',
          type: 'text',
          children: null
        }]
      }, {
        content: '',
        nesting: -1,
        tag: 'p',
        type: 'paragraph_close',
        children: null
      }]);
    });
  });

  describe('blockquote', () => {
    it('> a', () => {
      expect(Tokenizer.parse('> a')).to.eql([{
        content: '',
        nesting: 1,
        tag: 'blockquote',
        type: 'blockquote_open',
        children: null
      }, {
        content: '',
        nesting: 1,
        tag: 'p',
        type: 'paragraph_open',
        children: null
      }, {
        content: 'a',
        nesting: 0,
        tag: '',
        type: 'inline',
        children: [{
          content: 'a',
          nesting: 0,
          tag: '',
          type: 'text',
          children: null
        }]
      }, {
        content: '',
        nesting: -1,
        tag: 'p',
        type: 'paragraph_close',
        children: null
      }, {
        content: '',
        nesting: -1,
        tag: 'blockquote',
        type: 'blockquote_close',
        children: null
      }]);
    });

    it('> a\\n> a', () => {
      expect(Tokenizer.parse('> a\n> a')).to.eql([{
        content: '',
        nesting: 1,
        tag: 'blockquote',
        type: 'blockquote_open',
        children: null
      }, {
        content: '',
        nesting: 1,
        tag: 'p',
        type: 'paragraph_open',
        children: null
      }, {
        content: 'a',
        nesting: 0,
        tag: '',
        type: 'inline',
        children: [{
          children: null,
          content: 'a',
          nesting: 0,
          tag: '',
          type: 'text'
        }]
      }, {
        content: '',
        nesting: -1,
        tag: 'p',
        type: 'paragraph_close',
        children: null
      }, {
        content: '',
        nesting: 1,
        tag: 'p',
        type: 'paragraph_open',
        children: null
      }, {
        content: 'a',
        nesting: 0,
        tag: '',
        type: 'inline',
        children: [{
          content: 'a',
          nesting: 0,
          tag: '',
          type: 'text',
          children: null
        }]
      }, {
        content: '',
        nesting: -1,
        tag: 'p',
        type: 'paragraph_close',
        children: null
      }, {
        content: '',
        nesting: -1,
        tag: 'blockquote',
        type: 'blockquote_close',
        children: null
      }]);
    });
  });
});
