import { Token } from './token';

function parse(text) {
  const fixedText = text.trim();
  if (!fixedText) { return []; }

  return fixedText
    .lines()
    .map(line => parseLine(line.trim()))
    .flatten();
}

function parseLine(text) {
  if (text[0] === '>' && text[1] === ' ') {
    return wrap('blockquote', 'blockquote', paragraph(text.slice(2)));
  }

  return paragraph(text);
}

function paragraph(text) {
  const textToken = new Token('text', '', text, 0);
  const innerToken = new Token('inline', '', text, 0, [textToken]);

  return wrap('paragraph', 'p', [innerToken]);
}

function wrap(type, tag, tokens) {
  return [
    new Token(`${type}_open`, tag, '', 1),
    ...tokens,
    new Token(`${type}_close`, tag, '', -1)
  ];
}

export default { parse };
