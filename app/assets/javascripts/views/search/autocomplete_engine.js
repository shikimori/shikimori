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

  _searchUrl(phrase) {
    return this._url(this.fetchUrl, phrase);
  }

  _changeUrl(_phrase) {
  }
}
