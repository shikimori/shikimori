import IndexEngine from './index_engine';

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

    if (!Object.isEmpty(this.phrase)) {
      this._showAjax();
      this.debouncedSearch(this.phrase);
    }
  }

  _searchUrl(phrase) {
    return this._url(this.fetchUrl, phrase);
  }

  _changeUrl(_phrase) {
  }
}
