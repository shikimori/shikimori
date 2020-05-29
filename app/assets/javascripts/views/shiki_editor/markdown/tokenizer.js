import { Token } from './token';

export class Tokenizer {
  SPECIAL_TAGS = {
    paragraph: 'p',
    bullet_list: 'ul',
    list_item: 'li'
  }
  MAX_BBCODE_SIZE = 10;

  constructor(text) {
    this.text = text;

    this.index = -1;

    this.tokens = [];
    this.inlineTokens = [];
  }

  parse() {
    while (this.index < this.text.length - 1) {
      this.next(1);
      this.parseLine('');
    }

    return this.tokens.flatten();
  }

  next(steps = 1) {
    this.index += steps;
    this.char1 = this.text[this.index];
    this.char2 = this.text[this.index + 1];
    this.char3 = this.text[this.index + 2];
    this.char4 = this.text[this.index + 3];

    this.seq2 = this.char1 + this.char2;

    this.bbcode = this.char1 === '[' ? this.extractBbCode() : null;
  }

  parseLine(sequence) {
    const startIndex = this.index;

    outer: while (this.index <= this.text.length) { // eslint-disable-line no-restricted-syntax
      const { char1, seq2 } = this;
      const isStart = startIndex === this.index;
      const isEnd = char1 === '\n' || char1 === undefined;

      if (isEnd) {
        this.processParagraph(startIndex);
        break;
      }

      if (isStart) {
        switch (seq2) {
          case '> ':
            this.processBlockQuote(sequence, seq2);
            break outer;

          case '- ':
          case '+ ':
          case '* ':
            this.processBulletList();
            break outer;

          default:
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

      case '[i]':
        inlineTokens.push(this.tagOpen('em'));
        this.next(3);
        return;

      case '[/b]':
        inlineTokens.push(this.tagClose('strong'));
        this.next(4);
        return;

      case '[/i]':
        inlineTokens.push(this.tagClose('em'));
        this.next(4);
        return;

      default:
        break;
    }

    if (inlineTokens.last()?.type !== 'text') {
      inlineTokens.push(new Token('text', '', ''));
    }
    const token = inlineTokens.last();

    token.content += char1;
    this.next();
  }

  processParagraph(startIndex) {
    const text = this.text.slice(startIndex, this.index);

    this.push(this.tagOpen('paragraph'));
    this.push(new Token('inline', '', text, this.inlineTokens));
    this.push(this.tagClose('paragraph'));

    this.inlineTokens = [];
  }

  processBlockQuote(globalSequence, currentSequence) {
    const newSequence = globalSequence + currentSequence;
    this.push(this.tagOpen('blockquote'));

    do {
      this.next(currentSequence.length);
      this.parseLine(newSequence);

      if (this.char1 === '\n') {
        this.next();
      }
    } while (this.isContinued(newSequence));

    this.push(this.tagClose('blockquote'));
  }

  processBulletList() {
    this.push(this.tagOpen('bullet_list'));

    this.next(2);

    this.push(this.tagOpen('list_item'));
    this.parseLine();
    this.push(this.tagClose('list_item'));

    // if ((this.char2 === '-' || this.char2 === '+' || this.char2 === '*') && this.char3 === ' ') {
    //   this.next(3);
    //   this.parseLine();
    // }

    this.push(this.tagClose('bullet_list'));
  }

  tagOpen(type) {
    return new Token(
      `${type}_open`,
      this.SPECIAL_TAGS[type] || type,
      ''
    );
  }

  tagClose(type) {
    return new Token(
      `${type}_close`,
      this.SPECIAL_TAGS[type] || type,
      ''
    );
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
