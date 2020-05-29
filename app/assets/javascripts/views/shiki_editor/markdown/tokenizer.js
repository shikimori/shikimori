import { Token } from './token';

export class Tokenizer {
  constructor(text) {
    this.text = text;
    this.charIndex = -1;

    this.tokens = [];
  }

  parse() {
    while (this.charIndex < this.text.length - 1) {
      this.charIndex += 1;
      this.parseLine(this.charIndex);
    }

    return this.tokens.flatten();
  }

  parseLine(startIndex) {
    while (this.charIndex <= this.text.length) {
      const char = this.text[this.charIndex];

      const isStart = startIndex === this.charIndex;
      const isEnd = char === '\n' || char === undefined;

      const nextChar = this.text[this.charIndex + 1];
      const nextNextChar = this.text[this.charIndex + 2];

      if (isStart) {
        if (char === '>' && nextChar === ' ') {
          this.parseBlockQuote();
          break;
        }
      }

      if (isEnd) {
        this.paragraph(this.text.slice(startIndex, this.charIndex));
        break;
      }

      this.charIndex += 1;
    }
  }

  parseBlockQuote() {
    this.push(this.tagOpen('blockquote', 'blockquote'));

    this.charIndex += 2;
    this.parseLine(this.charIndex);

    const nextChar = this.text[this.charIndex + 1];
    const nextNextChar = this.text[this.charIndex + 2];
    if (nextChar === '>' && nextNextChar === ' ') {
      this.charIndex += 3;
      this.parseLine(this.charIndex);
    }

    this.push(this.tagClose('blockquote', 'blockquote'));
  }

  paragraph(text) {
    const inlineTokens = this.parseInline(text);
    const innerToken = new Token('inline', '', text, 0, inlineTokens);

    this.wrap('paragraph', 'p', innerToken);
  }

  parseInline(text) {
    return [
      new Token('text', '', text, 0)
    ];
  }

  wrap(type, tag, token) {
    this.push(this.tagOpen('paragraph', 'p'));
    this.push(token);
    this.push(this.tagClose('paragraph', 'p'));
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
