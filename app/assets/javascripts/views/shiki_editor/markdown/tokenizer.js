import { Token } from './token';

export class Tokenizer {
  SPECIAL_TAGS = {
    paragraph: 'p',
    bullet_list: 'ul',
    list_item: 'li',
    underline: 'span'
  }
  MAX_BBCODE_SIZE = 10;

  constructor(text) {
    this.text = text;

    this.tokens = [];
    this.inlineTokens = [];
  }

  parse() {
    this.index = -1;
    this.next();

    while (this.index < this.text.length) {
      this.parseLine('');
    }

    return this.tokens.flatten();
  }

  next(steps = 1) {
    this.index += steps;
    this.char1 = this.text[this.index];

    this.seq2 = this.char1 + this.text[this.index + 1];

    this.bbcode = this.char1 === '[' ? this.extractBbCode() : null;
  }

  parseLine(nestedSequence) {
    const startIndex = this.index;

    outer: while (this.index <= this.text.length) { // eslint-disable-line no-restricted-syntax
      const { char1, seq2 } = this;
      const isStart = startIndex === this.index;
      const isEnd = char1 === '\n' || char1 === undefined;

      if (isEnd) {
        this.processParagraph(startIndex);
        this.next();
        return;
      }

      if (isStart) {
        switch (seq2) {
          case '> ':
            this.processBlockQuote(nestedSequence, seq2);
            break outer;

          case '- ':
          case '+ ':
          case '* ':
            this.processBulletList(nestedSequence, seq2);
            break outer;
        }

        switch (this.bbcode) {
          case '[*]':
            this.processBulletList(
              nestedSequence,
              this.text[this.index + this.bbcode.length] === ' ' ?
                this.bbcode + ' ' :
                this.bbcode
            );
            break outer;
        }
      }

      this.processInline();
    }
  }

  processInline() {
    const { char1, inlineTokens } = this;

    switch (this.bbcode) {
      case '[b]':
        inlineTokens.push(this.tagOpen('strong'));
        this.next(this.bbcode.length);
        return;

      case '[/b]':
        inlineTokens.push(this.tagClose('strong'));
        this.next(4);
        return;

      case '[i]':
        inlineTokens.push(this.tagOpen('em'));
        this.next(3);
        return;

      case '[/i]':
        inlineTokens.push(this.tagClose('em'));
        this.next(4);
        return;

      case '[u]':
        inlineTokens.push(this.tagOpen('underline'));
        this.next(3);
        return;

      case '[/u]':
        inlineTokens.push(this.tagClose('underline'));
        this.next(4);
        return;

      case '[s]':
        inlineTokens.push(this.tagOpen('del'));
        this.next(3);
        return;

      case '[/s]':
        inlineTokens.push(this.tagClose('del'));
        this.next(4);
        return;

      default:
        break;
    }

    if (inlineTokens.last()?.type !== 'text') {
      inlineTokens.push(new Token('text', ''));
    }
    const token = inlineTokens.last();

    token.content += char1;
    this.next();
  }

  processParagraph(startIndex) {
    const text = this.text.slice(startIndex, this.index);

    this.push(this.tagOpen('paragraph'));
    this.push(new Token('inline', text, this.inlineTokens));
    this.push(this.tagClose('paragraph'));

    this.inlineTokens = [];
  }

  processBlockQuote(nestedSequence, tagSequence) {
    const newSequence = nestedSequence + tagSequence;

    this.push(this.tagOpen('blockquote'));

    do {
      this.next(tagSequence.length);
      this.parseLine(newSequence);
    } while (this.isContinued(newSequence));

    this.push(this.tagClose('blockquote'));
  }

  processBulletList(nestedSequence, tagSequence) {
    const newSequence = nestedSequence + tagSequence;

    this.push(this.tagOpen('bullet_list'));

    do {
      this.next(tagSequence.length);
      this.push(this.tagOpen('list_item'));
      this.processBulletListLines(nestedSequence, '  ');
      this.push(this.tagClose('list_item'));
    } while (this.isContinued(newSequence));

    this.push(this.tagClose('bullet_list'));
  }

  processBulletListLines(nestedSequence, tagSequence) {
    const newSequence = nestedSequence + tagSequence;
    let line = 0;

    do {
      if (line > 0) {
        this.next(newSequence.length);
      }

      this.parseLine(newSequence);
      line += 1;
    } while (this.isContinued(newSequence));
  }

  tagOpen(type) {
    return new Token(`${type}_open`, '');
  }

  tagClose(type) {
    return new Token(`${type}_close`, '');
  }

  push(token) {
    this.tokens.push(token);
  }

  isContinued(sequence) {
    return this.text.slice(this.index, this.index + sequence.length) === sequence;
  }

  extractBbCode() {
    for (let i = this.index + 1; i < this.index + this.MAX_BBCODE_SIZE; i++) {
      if (this.text[i] === ']') {
        return this.text.slice(this.index, i + 1);
      }
    }
    return null;
  }
}

Tokenizer.parse = function (text) {
  return new Tokenizer(text).parse();
};
