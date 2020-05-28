import { Token } from './token';

export class Tokenizer {
  constructor(text) {
    this.text = text;
    this.charIndex = -1;
    this.char = null;
    this.tokens = [];
  }

  parse() {
    while (this.charIndex < this.text.length - 1) {
      this.charIndex += 1;
      this.addTokens(this.parseLine(this.charIndex));
    }

    return this.tokens.flatten();
  }

  parseLine(startIndex) {
    while (this.charIndex < this.text.length) {
      const char = this.text[this.charIndex];

      if (char === '\n') {
        return this.paragraph(this.line(startIndex, this.charIndex));
      }
      this.charIndex += 1;
    }

    return this.paragraph(this.line(startIndex, this.text.length));

    // if (char === '>' && text[i + 1] === ' ') {
    // }
  }

  // parseLine(text) {
  //   if (text[0] === '>' && text[1] === ' ') {
  //     return this.wrap('blockquote', 'blockquote', this.paragraph(text.slice(2)));
  //   }

  //   return this.paragraph(text);
  // }

  line(startIndex, endIndex) {
    return this.text.slice(startIndex, endIndex);
  }

  addTokens(tokens) {
    this.tokens = this.tokens.concat(tokens);
  }

  addToken(token) {
    this.tokens.push(token);
  }

  paragraph(text) {
    const textToken = new Token('text', '', text, 0);
    const innerToken = new Token('inline', '', text, 0, [textToken]);

    return this.wrap('paragraph', 'p', [innerToken]);
  }

  wrap(type, tag, tokens) {
    return [
      new Token(`${type}_open`, tag, '', 1),
      ...tokens,
      new Token(`${type}_close`, tag, '', -1)
    ];
  }
}

Tokenizer.parse = function (text) {
  return new Tokenizer(text).parse();
};
