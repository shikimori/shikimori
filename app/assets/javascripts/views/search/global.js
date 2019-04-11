import CollectionSearch from './collection';

export default class GlobalSearch extends CollectionSearch {
  initialize() {
    super.initialize();
    this._bindHotkey();
  }

  get $collection() {
    return this.$root.find('.search-results');
  }

  // private functions
  _bindHotkey() {
    this.globalKeypressHandler = this._onGlobalKeypress.bind(this);

    $(document).on('keyup', this.globalKeypressHandler);
    $(document).one('turbolinks:before-cache', () => {
      $(document).off('keyup', this.globalKeypressHandler);
    });
  }

  _changeUrl(_url) {
  }

  _searchUrl(phrase) {
    return this._url(phrase, 'autocomplete');
  }

  _processResponse(response) {
    super._processResponse(response);
    this.$collection.children().eq(2).addClass('active');
  }

  _cancel() {
    if (Object.isEmpty(this.phrase)) {
      this._clearPhrase();
      this.$input.blur();
    } else {
      this._clearPhrase();
    }
    this._deactivate();
  }

  _activate() {
    if (Object.isEmpty(this.phrase)) {
      this._deactivate();
      return;
    }

    this.$collection.show();
    $('.l-top_menu-v2').addClass('is-global_search');

    super._activate();
  }

  _deactivate() {
    this.$collection
      .empty()
      .hide();
    $('.l-top_menu-v2').removeClass('is-global_search');

    this.isActive = false;
  }

  _showAjax() {
    this.$collection.find('.b-nothing_here').remove();
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
      if (this.isActive) {
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
