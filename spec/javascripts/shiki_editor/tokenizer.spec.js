import sugar from 'vendor/sugar'; // eslint-disable-line import/newline-after-import
import { expect } from 'chai';

sugar.extend();

import { Tokenizer } from 'views/shiki_editor/markdown/tokenizer';

function text(content) {
  return [{
    content: '',
    tag: 'p',
    type: 'paragraph_open',
    children: null
  }, {
    content,
    tag: '',
    type: 'inline',
    children: [{
      content,
      tag: '',
      type: 'text',
      children: null
    }]
  }, {
    content: '',
    tag: 'p',
    type: 'paragraph_close',
    children: null
  }];
}

describe('Tokenizer', () => {
  it('<empty>', () => {
    expect(Tokenizer.parse('')).to.eql([]);
  });

  describe('parahraphs', () => {
    it('z', () => {
      expect(Tokenizer.parse('z')).to.eql([
        ...text('z')
      ]);
    });

    it('zzz', () => {
      expect(Tokenizer.parse('zzz')).to.eql([
        ...text('zzz')
      ]);
    });

    it('zzz\\nxxx', () => {
      expect(Tokenizer.parse('zzz\nxxx')).to.eql([
        ...text('zzz'),
        ...text('xxx')
      ]);
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

    it('a[b]zxc[/b]A', () => {
      expect(Tokenizer.parse('a[b]zxc[/b]A')).to.eql([{
        content: '',
        tag: 'p',
        type: 'paragraph_open',
        children: null
      }, {
        content: 'a[b]zxc[/b]A',
        tag: '',
        type: 'inline',
        children: [{
          content: 'a',
          tag: '',
          type: 'text',
          children: null
        }, {
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
        }, {
          content: 'A',
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

  describe('blockquote', () => {
    it('> a', () => {
      expect(Tokenizer.parse('> a')).to.eql([{
        content: '',
        tag: 'blockquote',
        type: 'blockquote_open',
        children: null
      },
      ...text('a'),
      {
        content: '',
        tag: 'blockquote',
        type: 'blockquote_close',
        children: null
      }]);
    });

    it('> a\\n> b\\n> c', () => {
      expect(Tokenizer.parse('> a\n> b\n> c')).to.eql([{
        content: '',
        tag: 'blockquote',
        type: 'blockquote_open',
        children: null
      },
      ...text('a'),
      ...text('b'),
      ...text('c'),
      {
        content: '',
        tag: 'blockquote',
        type: 'blockquote_close',
        children: null
      }]);
    });

    it('> > a', () => {
      expect(Tokenizer.parse('> > a')).to.eql([{
        content: '',
        tag: 'blockquote',
        type: 'blockquote_open',
        children: null
      }, {
        content: '',
        tag: 'blockquote',
        type: 'blockquote_open',
        children: null
      },
      ...text('a'),
      {
        content: '',
        tag: 'blockquote',
        type: 'blockquote_close',
        children: null
      }, {
        content: '',
        tag: 'blockquote',
        type: 'blockquote_close',
        children: null
      }]);
    });

    it('> > a\\n> b', () => {
      expect(Tokenizer.parse('> > a\n> b')).to.eql([{
        content: '',
        tag: 'blockquote',
        type: 'blockquote_open',
        children: null
      }, {
        content: '',
        tag: 'blockquote',
        type: 'blockquote_open',
        children: null
      },
      ...text('a'),
      {
        content: '',
        tag: 'blockquote',
        type: 'blockquote_close',
        children: null
      },
      ...text('b'),
      {
        content: '',
        tag: 'blockquote',
        type: 'blockquote_close',
        children: null
      }]);
    });
  });

  describe('bullet_list', () => {
    it('- a', () => {
      expect(Tokenizer.parse('- a')).to.eql([{
        content: '',
        tag: 'ul',
        type: 'bullet_list_open',
        children: null
      }, {
        content: '',
        tag: 'li',
        type: 'list_item_open',
        children: null
      },
      ...text('a'),
      {
        content: '',
        tag: 'li',
        type: 'list_item_close',
        children: null
      }, {
        content: '',
        tag: 'ul',
        type: 'bullet_list_close',
        children: null
      }]);
    });

    it('- a\\n- b', () => {
      expect(Tokenizer.parse('- a\n- b')).to.eql([{
        content: '',
        tag: 'ul',
        type: 'bullet_list_open',
        children: null
      }, {
        content: '',
        tag: 'li',
        type: 'list_item_open',
        children: null
      },
      ...text('a'),
      {
        content: '',
        tag: 'li',
        type: 'list_item_close',
        children: null
      }, {
        content: '',
        tag: 'li',
        type: 'list_item_open',
        children: null
      },
      ...text('b'),
      {
        content: '',
        tag: 'li',
        type: 'list_item_close',
        children: null
      }, {
        content: '',
        tag: 'ul',
        type: 'bullet_list_close',
        children: null
      }]);
    });

    it('- test\\nn  zxc', () => {
      expect(Tokenizer.parse('- test\n  zxc')).to.eql([{
        content: '',
        tag: 'ul',
        type: 'bullet_list_open',
        children: null
      }, {
        content: '',
        tag: 'li',
        type: 'list_item_open',
        children: null
      },
      ...text('test'),
      ...text('zxc'),
      {
        content: '',
        tag: 'li',
        type: 'list_item_close',
        children: null
      }, {
        content: '',
        tag: 'ul',
        type: 'bullet_list_close',
        children: null
      }]);
    });

    it('- > test', () => {
      expect(Tokenizer.parse('- > test')).to.eql([{
        content: '',
        tag: 'ul',
        type: 'bullet_list_open',
        children: null
      }, {
        content: '',
        tag: 'li',
        type: 'list_item_open',
        children: null
      }, {
        content: '',
        tag: 'blockquote',
        type: 'blockquote_open',
        children: null
      },
      ...text('test'),
      {
        content: '',
        tag: 'blockquote',
        type: 'blockquote_close',
        children: null
      }, {
        content: '',
        tag: 'li',
        type: 'list_item_close',
        children: null
      }, {
        content: '',
        tag: 'ul',
        type: 'bullet_list_close',
        children: null
      }]);
    });

    it('[*] a', () => {
      expect(Tokenizer.parse('[*] a')).to.eql([{
        content: '',
        tag: 'ul',
        type: 'bullet_list_open',
        children: null
      }, {
        content: '',
        tag: 'li',
        type: 'list_item_open',
        children: null
      },
      ...text('a'),
      {
        content: '',
        tag: 'li',
        type: 'list_item_close',
        children: null
      }, {
        content: '',
        tag: 'ul',
        type: 'bullet_list_close',
        children: null
      }]);
    });

    it('[*]a', () => {
      expect(Tokenizer.parse('[*]a')).to.eql([{
        content: '',
        tag: 'ul',
        type: 'bullet_list_open',
        children: null
      }, {
        content: '',
        tag: 'li',
        type: 'list_item_open',
        children: null
      },
      ...text('a'),
      {
        content: '',
        tag: 'li',
        type: 'list_item_close',
        children: null
      }, {
        content: '',
        tag: 'ul',
        type: 'bullet_list_close',
        children: null
      }]);
    });
  });
});
