import CollectionSearch from './collection_search';

export default class GlobalSearch extends CollectionSearch {
  initialize() {
    super.initialize();

    this.isGlobalMode = true;
    this.$globalCollection = this.$root.find('.search-results');

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

    $(document).on('keyup', this.globalKeypressHandler);
    $(document).one('turbolinks:before-cache', () => {
      $(document).off('keyup', this.globalKeypressHandler);
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

  _cancel() {
    if (this.isGlobalMode) {
      if (Object.isEmpty(this.currentPhrase)) {
        this._clearPhrase();
        this.$input.blur();
      } else {
        this._clearPhrase();
      }
      this._deactivate();
    } else {
      super._cancel();
    }
  }

  _activate() {
    if (this.isGlobalMode) {
      if (Object.isEmpty(this.currentPhrase)) {
        this._deactivate();
        return;
      }

      this.$globalCollection.show();
      $('.l-top_menu-v2').addClass('is-global_search');
    }

    super._activate();
  }

  _deactivate() {
    if (this.isGlobalMode) {
      this.$globalCollection
        .empty()
        .hide();
      $('.l-top_menu-v2').removeClass('is-global_search');

      this.isActive = false;
    } else {
      super._deactivate();
    }
  }

  _showAjax() {
    if (this.isGlobalMode) {
      this.$globalCollection.find('.b-nothing_here').remove();
    }
    super._showAjax();
  }

  _onGlobalKeypress(e) {
    if (e.keyCode !== 47 && e.keyCode !== 191 && e.keyCode !== 27) { return; }

    const target = e.target || e.srcElement;
    const isIgnored = target.isContentEditable ||
      target.tagName === 'INPUT' ||
      target.tagName === 'SELECT' ||
      target.tagName === 'TEXTAREA';

    if (isIgnored) { return; }

    if (e.keyCode === 27) {
      if (this.isGlobalMode && this.isActive) {
        e.preventDefault();
        e.stopImmediatePropagation();

        this._cancel();
      }
    } else {
      e.preventDefault();
      e.stopImmediatePropagation();

      this.$input.focus();
      this.$input[0].setSelectionRange(0, this.$input[0].value.length);
    }
  }
}
