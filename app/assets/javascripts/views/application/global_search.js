import CollectionSearch from './collection_search';

export default class GlobalSearch extends CollectionSearch {
  initialize() {
    super.initialize();
    this._bindHotkey();
  }

  // private functions
  _bindHotkey() {
    this.globalKeypressHandler = this._onGlobalKeypress.bind(this);

    $(document).on('keypress', this.globalKeypressHandler);
    $(document).one('turbolinks:before-cache', () => {
      $(document).off('keypress', this.globalKeypressHandler);
    });
  }

  _onGlobalKeypress(e) {
    console.log('_onGlobalKeypress');
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
