export class Tokenizer {
  constructor(text) {
    this.text = text.trim();
  }

  parse() {
    if (!this.text) { return []; }

    return [];
  }
}

Tokenizer.parse = function (text) {
  return new Tokenizer(text).parse();
};
