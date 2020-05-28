export default function quillToMarkdown(deltas) {
  return deltas
    .map(delta => {
      if (delta.attributes?.bold) {
        return `[b]${delta.insert}[/b]`;
      }
      if (delta.attributes?.italic) {
        return `[i]${delta.insert}[/i]`;
      }
      return delta.insert;
    })
    .join('');
}
