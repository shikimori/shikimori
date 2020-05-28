export default function markdownToQuill(text) {
  if (!text) { return []; }

  return [{
    insert: text
  }];
}
