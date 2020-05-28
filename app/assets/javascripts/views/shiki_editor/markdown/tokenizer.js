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

      if (char === '\n' || char === undefined) {
        this.paragraph(this.line(startIndex, this.charIndex));
        break;
      }

      const nextChar = this.text[this.charIndex + 1];
      if (char === '>' && nextChar === ' ') {
        this.parseBlockQuote(this.charIndex);
        break;
      }

      this.charIndex += 1;
    }
  }

  parseBlockQuote(startIndex) {
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

    this.addTokens(
      this.wrap('paragraph', 'p', [innerToken])
    );
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
