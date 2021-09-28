import $with from './with';

export function isGetSelectionTextSupported() {
  return typeof window.getSelection !== 'undefined';
}

export function getSelectionText() {
  const html = getSelectionHtml().replace(/<br.*?>/g, '<--BR-->');
  return $(`<div>${html}</div>`).text().replace(/<--BR-->/g, '\n').trim();
}

export function getSelectionHtml() {
  let html = '';

  if (isGetSelectionTextSupported()) {
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

  let $html = $(`<div>${html}</div>`);

  if (html.match(/<div class="body"/)) {
    $html = $with('div.body', $html);
  }

  const namesLocale = document.body.getAttribute('data-localized_names');
  const genresLocale = document.body.getAttribute('data-localized_genres');

  $html.find(namesLocale === 'ru' ? '.name-en' : '.name-ru').remove();
  $html.find(genresLocale === 'ru' ? '.genre-en' : '.genre-ru').remove();

  return $html.html();
}
