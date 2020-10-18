import $with from './with';

export function getSelectionText() {
  return $(`<div>${getSelectionHtml()}</div>`).text();
}

export function getSelectionHtml() {
  let html = '';

  if (typeof window.getSelection !== 'undefined') {
    const sel = window.getSelection();
    if (sel.rangeCount) {
      const container = document.createElement('div');
      for (let i = 0, len = sel.rangeCount; i < len; i += 1) {
        container.appendChild(sel.getRangeAt(i).cloneContents());
      }
      html = container.innerHTML;
    }
  } else if (typeof document.selection !== 'undefined') {
    if (document.selection.type === 'Text') {
      html = document.selection.createRange().htmlText;
    }
  }

  if (html.match(/<div class="body"/)) {
    return $with('div.body', $(html)).html();
  }

  return html;
}
