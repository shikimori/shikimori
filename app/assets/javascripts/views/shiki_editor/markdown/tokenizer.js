import { Token } from './token';

export class Tokenizer {
  constructor(text) {
    this.text = text.trim();
  }

  parse() {
    if (!this.text) { return []; }

    return this.text.lines().map(line => this.parseLine(line)).flatten();
  }

  parseLine(text) {
    return this.wrap('paragraph', 'p', text);
  }

  wrap(type, tag, text) {
    const textToken = new Token('text', '', text, 0);
    const innerToken = new Token('inline', '', text, 0, [textToken]);

    return [
      new Token(`${type}_open`, tag, '', 1),
      innerToken,
      new Token(`${type}_close`, tag, '', -1)
    ];
  }
}

Tokenizer.parse = function (text) {
  return new Tokenizer(text).parse();
};
