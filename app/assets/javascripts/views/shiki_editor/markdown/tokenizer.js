import { Token } from './token';

export class Tokenizer {
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
    if (!this.inlineTokens.length) {
      this.inlineTokens.push(new Token('text', '', '', 0));
    }
    const token = this.inlineTokens.last();

    token.content += this.char1;
    this.next(1);
  }

  processParagraph(startIndex) {
    const text = this.text.slice(startIndex, this.charIndex);

    this.push(this.tagOpen('paragraph', 'p'));
    this.push(new Token('inline', '', text, 0, this.inlineTokens));
    this.push(this.tagClose('paragraph', 'p'));

    this.inlineTokens = [];
  }

  processBlockQuote() {
    this.push(this.tagOpen('blockquote', 'blockquote'));

    this.next(2);
    this.parseLine(this.charIndex);

    if (this.char2 === '>' && this.char3 === ' ') {
      this.next(3);
      this.parseLine(this.charIndex);
    }

    this.push(this.tagClose('blockquote', 'blockquote'));
  }

  tagOpen(type, tag) {
    return new Token(`${type}_open`, tag, '', 1);
  }

  tagClose(type, tag) {
    return new Token(`${type}_close`, tag, '', -1);
  }

  push(token) {
    this.tokens.push(token);
  }
}

Tokenizer.parse = function (text) {
  return new Tokenizer(text).parse();
};
