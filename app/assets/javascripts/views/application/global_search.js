import CollectionSearch from './collection_search';

export default class GlobalSearch extends CollectionSearch {
  initialize() {
    this.isGlobalMode = true;
    this.$globalCollection = this.$root.find('.search-results');
    super.initialize();

    this._bindHotkey();
  }

  get $collection() {
    return this.isGlobalMode ? this.$globalCollection : super.$collection;
  }

  get isGlobalMode() {
    return this._isGlobalMode;
  }

  set isGlobalMode(value) {
    this._isGlobalMode = value;
  }

  // private functions
  _bindHotkey() {
    this.globalKeypressHandler = this._onGlobalKeypress.bind(this);

    $(document).on('keypress', this.globalKeypressHandler);
    $(document).one('turbolinks:before-cache', () => {
      $(document).off('keypress', this.globalKeypressHandler);
    });
  }

  _changeUrl(url) {
    if (this.isGlobalMode) { return; }

    super._changeUrl(url);
  }

  _searchUrl(phrase) {
    if (this.isGlobalMode) {
      return this._url(phrase, 'autocomplete');
    }

    return super._searchUrl(phrase);
  }

  _onGlobalKeypress(e) {
    if (e.keyCode !== 47) { return; }

    const target = e.target || e.srcElement;
    const isIgnored = target.isContentEditable ||
      target.tagName === 'INPUT' ||
      target.tagName === 'SELECT' ||
      target.tagName === 'TEXTAREA';

    if (isIgnored) { return; }

    e.preventDefault();
    e.stopImmediatePropagation();

    this.$input.focus();
    this.$input[0].setSelectionRange(0, this.$input[0].value.length);
  }
}
