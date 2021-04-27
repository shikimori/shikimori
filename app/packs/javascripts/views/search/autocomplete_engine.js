import IndexEngine from './index_engine';

const VARIANT_SELECTOR = '.b-db_entry-variant-list_item';

export default class AutocompleteEngine extends IndexEngine {
  constructor(fetchUrl, $content) {
    super();

    this.fetchUrl = fetchUrl;
    this._$content = $content;
    this.isAutocomplete = true;
  }

  get $content() {
    return this._$content;
  }

  get phrase() {
    return this._phrase;
  }

  set phrase(value) {
    this._phrase = value;
    this._buildSearchPromise();

    if (!Object.isEmpty(this.phrase)) {
      this._showAjax();
      this.debouncedSearch(this.phrase);
    } else {
      this._resolveSearchPromise();
    }
  }

  _responseToHtml(response) {
    const $html = $(super._responseToHtml(response));

    $html.find('a').changeTag('span');
    $html.find('.linkeable, .bubbled').removeClass('linkeable bubbled');

    $html.filter(VARIANT_SELECTOR).each((_index, node) => {
      node.classList.add('linkeable');
      node.setAttribute('href', $(node).find('.name .b-link').attr('href'));
    });

    return $html;
  }

  _searchUrl(phrase) {
    return this._url(this.fetchUrl, phrase);
  }

  _changeUrl(_phrase) {
  }
}
