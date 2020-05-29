import { Token } from './token';

export class Tokenizer {
  SPECIAL_TAGS = {
    paragraph: 'p'
  }

  constructor(text) {
    this.text = text;

    this.charIndex = -1;
    this.char1 = null;
    this.char2 = null;
    this.char3 = null;

    this.tokens = [];
    this.inlineTokens = [];
  }

  parse() {
    while (this.charIndex < this.text.length - 1) {
      this.next(1);
      this.parseLine(this.charIndex);
    }

    return this.tokens.flatten();
  }

  next(steps) {
    this.charIndex += steps;
    this.char1 = this.text[this.charIndex];
    this.char2 = this.text[this.charIndex + 1];
    this.char3 = this.text[this.charIndex + 2];
    this.char4 = this.text[this.charIndex + 3];
  }

  parseLine(startIndex) {
    while (this.charIndex <= this.text.length) {
      const { char1, char2 } = this;
      const isStart = startIndex === this.charIndex;
      const isEnd = char1 === '\n' || char1 === undefined;

      if (isEnd) {
        this.processParagraph(startIndex);
        break;
      } else if (isStart && char1 === '>' && char2 === ' ') {
        this.processBlockQuote();
        break;
      } else {
        this.processInline();
      }
    }
  }

  processInline() {
    const { char1, char2, char3, char4, inlineTokens } = this;

    if (char1 === '[' && char3 === ']') {
      if (char2 === 'b') {
        inlineTokens.push(this.tagOpen('strong'));
        this.next(3);
        return;
      }
      if (char2 === 'i') {
        inlineTokens.push(this.tagOpen('em'));
        this.next(3);
        return;
      }
    }
    if (char1 === '[' && char2 === '/' && char4 === ']') {
      if (char3 === 'b') {
        inlineTokens.push(this.tagClose('strong'));
        this.next(4);
        return;
      }
      if (char3 === 'i') {
        inlineTokens.push(this.tagClose('em'));
        this.next(4);
        return;
      }
    }

    if (inlineTokens.last()?.type !== 'text') {
      inlineTokens.push(new Token('text', '', ''));
    }
    const token = inlineTokens.last();

    token.content += char1;
    this.next(1);
  }

  processParagraph(startIndex) {
    const text = this.text.slice(startIndex, this.charIndex);

    this.push(this.tagOpen('paragraph'));
    this.push(new Token('inline', '', text, this.inlineTokens));
    this.push(this.tagClose('paragraph'));

    this.inlineTokens = [];
  }

  processBlockQuote() {
    this.push(this.tagOpen('blockquote'));

    this.next(2);
    this.parseLine(this.charIndex);

    if (this.char2 === '>' && this.char3 === ' ') {
      this.next(3);
      this.parseLine(this.charIndex);
    }

    this.push(this.tagClose('blockquote'));
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
}

Tokenizer.parse = function (text) {
  return new Tokenizer(text).parse();
};
