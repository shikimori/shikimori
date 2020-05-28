import { Token } from './token';

function parse(rawText) {
  const text = rawText.trim();
  if (!text) { return []; }

  const tokens = [];
  // const stack = [];

  let lineStart = 0;

  for (let i = 0; i <= text.length; i++) {
    const char = text[i];

    if (char === '\n' || char === undefined) {
      const line = text.slice(lineStart, i);

      tokens.push(paragraph(line));
      lineStart = i + 1;
      continue;
    }

    // if (char === '>' && text[i + 1] === ' ') {
    // }
  }

  return tokens.flatten();
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

export default {
  parse,
  parseLine,
  paragraph,
  wrap
};
