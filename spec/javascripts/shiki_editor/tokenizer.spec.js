import sugar from 'vendor/sugar'; // eslint-disable-line import/newline-after-import
import { expect } from 'chai';

sugar.extend();

import { Tokenizer } from 'views/shiki_editor/markdown/tokenizer';

function text(content) {
  return [{
    content: '',
    type: 'paragraph_open',
    children: null
  }, {
    content,
    type: 'inline',
    children: [{
      content,
      type: 'text',
      children: null
    }]
  }, {
    content: '',
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
        type: 'paragraph_open',
        children: null
      }, {
        content: '[b]zxc[/b]',
        type: 'inline',
        children: [{
          content: '',
          type: 'strong_open',
          children: null
        }, {
          content: 'zxc',
          type: 'text',
          children: null
        }, {
          content: '',
          type: 'strong_close',
          children: null
        }]
      }, {
        content: '',
        type: 'paragraph_close',
        children: null
      }]);
    });

    it('a[b]zxc[/b]A', () => {
      expect(Tokenizer.parse('a[b]zxc[/b]A')).to.eql([{
        content: '',
        type: 'paragraph_open',
        children: null
      }, {
        content: 'a[b]zxc[/b]A',
        type: 'inline',
        children: [{
          content: 'a',
          type: 'text',
          children: null
        }, {
          content: '',
          type: 'strong_open',
          children: null
        }, {
          content: 'zxc',
          type: 'text',
          children: null
        }, {
          content: '',
          type: 'strong_close',
          children: null
        }, {
          content: 'A',
          type: 'text',
          children: null
        }]
      }, {
        content: '',
        type: 'paragraph_close',
        children: null
      }]);
    });
  });

  describe('underline', () => {
    it('[u]zxc[/u]', () => {
      expect(Tokenizer.parse('[u]zxc[/u]')).to.eql([{
        content: '',
        type: 'paragraph_open',
        children: null
      }, {
        content: '[u]zxc[/u]',
        type: 'inline',
        children: [{
          content: '',
          type: 'underline_open',
          children: null
        }, {
          content: 'zxc',
          type: 'text',
          children: null
        }, {
          content: '',
          type: 'underline_close',
          children: null
        }]
      }, {
        content: '',
        type: 'paragraph_close',
        children: null
      }]);
    });
  });

  describe('deleted', () => {
    it('[s]zxc[/s]', () => {
      expect(Tokenizer.parse('[s]zxc[/s]')).to.eql([{
        content: '',
        type: 'paragraph_open',
        children: null
      }, {
        content: '[s]zxc[/s]',
        type: 'inline',
        children: [{
          content: '',
          type: 'del_open',
          children: null
        }, {
          content: 'zxc',
          type: 'text',
          children: null
        }, {
          content: '',
          type: 'del_close',
          children: null
        }]
      }, {
        content: '',
        type: 'paragraph_close',
        children: null
      }]);
    });
  });

  describe('blockquote', () => {
    it('> a', () => {
      expect(Tokenizer.parse('> a')).to.eql([{
        content: '',
        type: 'blockquote_open',
        children: null
      },
      ...text('a'),
      {
        content: '',
        type: 'blockquote_close',
        children: null
      }]);
    });

    it('> a\\n> b\\n> c', () => {
      expect(Tokenizer.parse('> a\n> b\n> c')).to.eql([{
        content: '',
        type: 'blockquote_open',
        children: null
      },
      ...text('a'),
      ...text('b'),
      ...text('c'),
      {
        content: '',
        type: 'blockquote_close',
        children: null
      }]);
    });

    it('> > a', () => {
      expect(Tokenizer.parse('> > a')).to.eql([{
        content: '',
        type: 'blockquote_open',
        children: null
      }, {
        content: '',
        type: 'blockquote_open',
        children: null
      },
      ...text('a'),
      {
        content: '',
        type: 'blockquote_close',
        children: null
      }, {
        content: '',
        type: 'blockquote_close',
        children: null
      }]);
    });

    it('> > a\\n> b', () => {
      expect(Tokenizer.parse('> > a\n> b')).to.eql([{
        content: '',
        type: 'blockquote_open',
        children: null
      }, {
        content: '',
        type: 'blockquote_open',
        children: null
      },
      ...text('a'),
      {
        content: '',
        type: 'blockquote_close',
        children: null
      },
      ...text('b'),
      {
        content: '',
        type: 'blockquote_close',
        children: null
      }]);
    });
  });

  describe('bullet_list', () => {
    it('- a', () => {
      expect(Tokenizer.parse('- a')).to.eql([{
        content: '',
        type: 'bullet_list_open',
        children: null
      }, {
        content: '',
        type: 'list_item_open',
        children: null
      },
      ...text('a'),
      {
        content: '',
        type: 'list_item_close',
        children: null
      }, {
        content: '',
        type: 'bullet_list_close',
        children: null
      }]);
    });

    it('- a\\n- b', () => {
      expect(Tokenizer.parse('- a\n- b')).to.eql([{
        content: '',
        type: 'bullet_list_open',
        children: null
      }, {
        content: '',
        type: 'list_item_open',
        children: null
      },
      ...text('a'),
      {
        content: '',
        type: 'list_item_close',
        children: null
      }, {
        content: '',
        type: 'list_item_open',
        children: null
      },
      ...text('b'),
      {
        content: '',
        type: 'list_item_close',
        children: null
      }, {
        content: '',
        type: 'bullet_list_close',
        children: null
      }]);
    });

    it('- test\\nn  zxc', () => {
      expect(Tokenizer.parse('- test\n  zxc')).to.eql([{
        content: '',
        type: 'bullet_list_open',
        children: null
      }, {
        content: '',
        type: 'list_item_open',
        children: null
      },
      ...text('test'),
      ...text('zxc'),
      {
        content: '',
        type: 'list_item_close',
        children: null
      }, {
        content: '',
        type: 'bullet_list_close',
        children: null
      }]);
    });

    it('- > test', () => {
      expect(Tokenizer.parse('- > test')).to.eql([{
        content: '',
        type: 'bullet_list_open',
        children: null
      }, {
        content: '',
        type: 'list_item_open',
        children: null
      }, {
        content: '',
        type: 'blockquote_open',
        children: null
      },
      ...text('test'),
      {
        content: '',
        type: 'blockquote_close',
        children: null
      }, {
        content: '',
        type: 'list_item_close',
        children: null
      }, {
        content: '',
        type: 'bullet_list_close',
        children: null
      }]);
    });

    it('[*] a', () => {
      expect(Tokenizer.parse('[*] a')).to.eql([{
        content: '',
        type: 'bullet_list_open',
        children: null
      }, {
        content: '',
        type: 'list_item_open',
        children: null
      },
      ...text('a'),
      {
        content: '',
        type: 'list_item_close',
        children: null
      }, {
        content: '',
        type: 'bullet_list_close',
        children: null
      }]);
    });

    it('[*]a', () => {
      expect(Tokenizer.parse('[*]a')).to.eql([{
        content: '',
        type: 'bullet_list_open',
        children: null
      }, {
        content: '',
        type: 'list_item_open',
        children: null
      },
      ...text('a'),
      {
        content: '',
        type: 'list_item_close',
        children: null
      }, {
        content: '',
        type: 'bullet_list_close',
        children: null
      }]);
    });
  });

  describe('code_block', () => {
    it('```\\nzxc\\nvbn\\n```', () => {
      expect(Tokenizer.parse('```\nzxc\nvbn\n```')).to.eql([{
        content: 'zxc\nvbn',
        type: 'code_block',
        children: null
      }]);
    });

    it('qwe\\n```\\nzxc\\nvbn\\n```\\nrty', () => {
      expect(Tokenizer.parse('qwe\n```\nzxc\nvbn\n```\nrty')).to.eql([
        ...text('qwe'),
        {
          content: 'zxc\nvbn',
          type: 'code_block',
          children: null
        },
        ...text('rty')
      ]);
    });

    it('```\\nzxc', () => {
      expect(Tokenizer.parse('```\nzxc')).to.eql([{
        content: 'zxc',
        type: 'code_block',
        children: null
      }]);
    });
  });
});
