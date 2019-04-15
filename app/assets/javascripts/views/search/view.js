import View from 'views/application/view';

// import GlobalSearch from './global';
// import CollectionSearch from './collection';

import JST from 'helpers/jst';

const ITEM_SELECTOR = '.b-db_entry-variant-list_item, .search-mode';

export default class SearchView extends View {
  initialize() {
    this.$input = this.$('.field input');

    this.phrase = this.inputSearchPhrase;
    this.isActive = false;
    this.currentMode = this.hasCollection ? 'collection' : 'anime';

    // new GlobalSearch(this.$node);
    this._bindGlobalHotkey();

    this.$input
      .on('focus', () => this._activate())
      .on('change blur paste keyup', () => this.phrase = this.inputSearchPhrase);

    this.$('.field .clear')
      .on('click', () => this._clearPhrase(true));

    this.$collection
      .on('click', '.search-mode', ({ currentTarget }) => this._selectItem(currentTarget));
  }

  get inputSearchPhrase() {
    return this.$input.val().trim();
  }

  get hasCollection() {
    return !!$('.b-search-results').length;
  }

  get $collection() {
    return this.$root.find('.search-results');
  }

  get $activeItem() {
    return this.$collection.find(`${ITEM_SELECTOR}.active`);
  }

  get isSearching() {
    return !Object.isEmpty(this.phrase);
  }

  get phrase() {
    return this._phrase;
  }

  set phrase(value) {
    const trimmedValue = value.trim();
    // const priorPhrase = this._phrase;

    if (this._phrase === trimmedValue) { return; }

    this._phrase = trimmedValue;
    if (this.$input[0].value !== value) {
      this.$input[0].value = value;
    }

    // if (priorPhrase !== undefined) { // it is undefined in constructor
    //   this._activate();
    //   this.debouncedSearch(this._phrase);
    // }

    this.$input.toggleClass('has-value', !Object.isEmpty(this._phrase));
  }

  // private functions
  _activate() {
    console.log(this.currentMode);
    if (this.isActive) { return; }

    this.isActive = true;
    $('.l-top_menu-v2').addClass('is-global_search');

    this.$collection.html(
      JST['search/options']({
        currentMode: this.currentMode,
        hasCollection: this.hasCollection
      })
    );
  }

  _deactivate() {
    this.isActive = false;
    $('.l-top_menu-v2').removeClass('is-global_search');
    this.$input.blur();
  }

  _cancel() {
    if (Object.isEmpty(this.phrase)) {
      this._deactivate();
    } else {
      this._clearPhrase();
    }
  }

  _clearPhrase(isFocus) {
    this.phrase = '';

    if (isFocus) {
      this.$input.focus();
    }
  }

  _selectItem(node, doScroll) {
    this._deselectItems();

    if (this.isSearching) {
      this.currentItem = node;
    } else {
      this.currentMode = $(node).data('mode');
    }
    console.log(this.currentMode);

    const $node = $(node);
    $node.addClass('active');

    if (doScroll) {
      this._scrollToItem($node);
    }
  }

  _deselectItems() {
    this.$collection.find(ITEM_SELECTOR).removeClass('active');
  }

  _scrollToItem($node) {
    // let didScroll = false;

    const nodeTop = $node.offset().top;
    const nodeHeight = $node.outerHeight();

    const windowTop = window.scrollY || document.documentElement.scrollTop;
    const windowHeight = $(window).height();

    if (nodeTop < windowTop) {
      // didScroll = true;
      if ($node.is(':first-child')) {
        window.scrollTo(0, 0);
      } else {
        window.scrollTo(0, nodeTop - 10);
      }
    } else if (nodeTop + nodeHeight > windowTop + windowHeight) {
      // didScroll = true;
      window.scrollTo(0, windowTop + (nodeTop + nodeHeight) - (windowTop + windowHeight) + 10);
    }

    // NOTE: no need in it after switching from mouseover to mousemove
    // to prevent item selection by mouseover event
    // it could happen if mouse cursor currently is over some item
    // if (didScroll) {
    //   document.body.style.pointerEvents = 'none';

    //   if (!this.debouncedEnableMouseEvents) {
    //     this.debouncedEnableMouseEvents = debounce(250, () => (
    //       document.body.style.pointerEvents = ''
    //     ));
    //   }
    //   this.debouncedEnableMouseEvents();
    // }
  }

  // global hotkeys
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

  _onGlobalEsc(e) {
    e.preventDefault();
    e.stopImmediatePropagation();

    this._cancel();
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
      this._selectItem(item, true);
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
      this._selectItem(item, true);
    } else if (this.isSearching) {
      this._deselectItems();
    }
  }
}
