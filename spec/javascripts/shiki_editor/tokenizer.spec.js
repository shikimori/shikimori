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
        tag: 'p',
        type: 'paragraph_open',
        children: null
      }, {
        content: 'z',
        tag: '',
        type: 'inline',
        children: [{
          content: 'z',
          tag: '',
          type: 'text',
          children: null
        }]
      }, {
        content: '',
        tag: 'p',
        type: 'paragraph_close',
        children: null
      }]);
    });

    it('zzz', () => {
      expect(Tokenizer.parse('zzz')).to.eql([{
        content: '',
        tag: 'p',
        type: 'paragraph_open',
        children: null
      }, {
        content: 'zzz',
        tag: '',
        type: 'inline',
        children: [{
          content: 'zzz',
          tag: '',
          type: 'text',
          children: null
        }]
      }, {
        content: '',
        tag: 'p',
        type: 'paragraph_close',
        children: null
      }]);
    });

    it('zzz\\nxxx', () => {
      expect(Tokenizer.parse('zzz\nxxx')).to.eql([{
        content: '',
        tag: 'p',
        type: 'paragraph_open',
        children: null
      }, {
        content: 'zzz',
        tag: '',
        type: 'inline',
        children: [{
          content: 'zzz',
          tag: '',
          type: 'text',
          children: null
        }]
      }, {
        content: '',
        tag: 'p',
        type: 'paragraph_close',
        children: null
      }, {
        content: '',
        tag: 'p',
        type: 'paragraph_open',
        children: null
      }, {
        content: 'xxx',
        tag: '',
        type: 'inline',
        children: [{
          content: 'xxx',
          tag: '',
          type: 'text',
          children: null
        }]
      }, {
        content: '',
        tag: 'p',
        type: 'paragraph_close',
        children: null
      }]);
    });
  });

  describe('strong', () => {
    it('[b]zxc[/b]', () => {
      expect(Tokenizer.parse('[b]zxc[/b]')).to.eql([{
        content: '',
        tag: 'p',
        type: 'paragraph_open',
        children: null
      }, {
        content: '[b]zxc[/b]',
        tag: '',
        type: 'inline',
        children: [{
          content: '',
          tag: 'strong',
          type: 'strong_open',
          children: null
        }, {
          content: 'zxc',
          tag: '',
          type: 'text',
          children: null
        }, {
          content: '',
          tag: 'strong',
          type: 'strong_close',
          children: null
        }]
      }, {
        content: '',
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
        tag: 'blockquote',
        type: 'blockquote_open',
        children: null
      }, {
        content: '',
        tag: 'p',
        type: 'paragraph_open',
        children: null
      }, {
        content: 'a',
        tag: '',
        type: 'inline',
        children: [{
          content: 'a',
          tag: '',
          type: 'text',
          children: null
        }]
      }, {
        content: '',
        tag: 'p',
        type: 'paragraph_close',
        children: null
      }, {
        content: '',
        tag: 'blockquote',
        type: 'blockquote_close',
        children: null
      }]);
    });

    it('> a\\n> a', () => {
      expect(Tokenizer.parse('> a\n> a')).to.eql([{
        content: '',
        tag: 'blockquote',
        type: 'blockquote_open',
        children: null
      }, {
        content: '',
        tag: 'p',
        type: 'paragraph_open',
        children: null
      }, {
        content: 'a',
        tag: '',
        type: 'inline',
        children: [{
          children: null,
          content: 'a',
          tag: '',
          type: 'text'
        }]
      }, {
        content: '',
        tag: 'p',
        type: 'paragraph_close',
        children: null
      }, {
        content: '',
        tag: 'p',
        type: 'paragraph_open',
        children: null
      }, {
        content: 'a',
        tag: '',
        type: 'inline',
        children: [{
          content: 'a',
          tag: '',
          type: 'text',
          children: null
        }]
      }, {
        content: '',
        tag: 'p',
        type: 'paragraph_close',
        children: null
      }, {
        content: '',
        tag: 'blockquote',
        type: 'blockquote_close',
        children: null
      }]);
    });
  });
});
