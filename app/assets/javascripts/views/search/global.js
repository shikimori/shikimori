import CollectionSearch from './collection';

const ITEM_SELECTOR = '.b-db_entry-variant-list_item';

export default class GlobalSearch extends CollectionSearch {
  initialize() {
    super.initialize();

    this._bindGlobalHotkey();

    this.$collection.on('mouseover', ITEM_SELECTOR, ({ currentTarget }) => (
      this._selectItem(currentTarget)
    ));
  }

  get $collection() {
    return this.$root.find('.search-results');
  }

  get $activeItem() {
    return this.$collection.find(`${ITEM_SELECTOR}.active`);
  }

  // handlers
  _onGlobalKeyup(e) {
    if (e.keyCode === 27) {
      this._onGlobalEsc(e);
    } else if (e.keyCode === 47 || e.keyCode === 191) {
      this._onGlobalSlash(e);
    }
  }

  _onGlobalKeydown(e) {
    if (e.keyCode === 40) {
      this._onGlobalDown(e);
    } else if (e.keyCode === 38) {
      this._onGlobalUp(e);
    }
  }

  _onGlobalEsc(e) {
    if (!this.isActive) { return; }

    e.preventDefault();
    e.stopImmediatePropagation();

    this._cancel();
  }

  _onGlobalSlash(e) {
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

  _onGlobalDown(e) {
    const { $activeItem } = this;
    const item = $activeItem.length ?
      $activeItem.next()[0] :
      this.$collection.find(ITEM_SELECTOR).first()[0];

    if (this.isActive) {
      e.preventDefault();
      e.stopImmediatePropagation();
    }

    if (item) {
      this._selectItem(item);
    }
  }

  _onGlobalUp(e) {
    const { $activeItem } = this;
    const item = $activeItem.prev()[0];

    if (this.isActive) {
      e.preventDefault();
      e.stopImmediatePropagation();
    }

    if (item) {
      this._selectItem(item);
    }
  }

  // private functions
  _bindGlobalHotkey() {
    this.globalKeyupHandler = this._onGlobalKeyup.bind(this);
    this.globalKeydownHandler = this._onGlobalKeydown.bind(this);

    $(document).on('keyup', this.globalKeyupHandler);
    $(document).on('keydown', this.globalKeydownHandler);

    $(document).one('turbolinks:before-cache', () => {
      $(document).off('keyup', this.globalKeyupHandler);
      $(document).off('keydown', this.globalKeydownHandler);
    });
  }

  _searchUrl(phrase) {
    return this._url(phrase, 'autocomplete');
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

  _selectItem(node) {
    this.currentItem = node;
    $(node).siblings().removeClass('active');
    $(node).addClass('active');
  }

  _changeUrl(_url) {}
}
