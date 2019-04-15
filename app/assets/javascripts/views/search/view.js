import View from 'views/application/view';

import AutocompleteEngine from './autocomplete_engine';
// import CollectionSearch from './collection';

import JST from 'helpers/jst';

const VARIANT_SELECTOR = '.b-db_entry-variant-list_item';
const ITEM_SELECTOR = `${VARIANT_SELECTOR}, .search-mode`;

export default class SearchView extends View {
  initialize() {
    this.$input = this.$('.field input');

    this.phrase = this.inputSearchPhrase;
    this.isActive = false;
    this.currentMode = this.hasCollection ? 'collection' : 'anime';

    this._bindGlobalHotkey();

    this.$input
      .on('focus', () => this._activate())
      .on('change blur paste keyup', () => this.phrase = this.inputSearchPhrase);

    this.$('.field .clear')
      .on('click', () => this._clearPhrase(true));

    this.$content
      .on('click', '.search-mode', ({ currentTarget }) => {
        this._selectItem(currentTarget);
        this.$input.focus();
      })
      .on('mousemove', VARIANT_SELECTOR, ({ currentTarget }) => {
        // better than mouseover cause it does not trigger after keyboard scroll
        if (this.currentItem !== currentTarget) {
          this._selectItem(currentTarget, false);
        }
      });
  }

  get hasCollection() {
    return !!$('.b-search-results').length;
  }

  get currentMode() {
    return this._currentMode;
  }

  set currentMode(value) {
    this._currentMode = value;
    this.searchEngine = new AutocompleteEngine(
      this.$node.data(`autocomplete_${this.currentMode}_url`),
      this.$content
    );
  }

  get $content() {
    return this.$root.find('.search-results');
  }

  get $activeItem() {
    return this.$content.find(ITEM_SELECTOR).filter('.active');
  }

  get isSearching() {
    return !Object.isEmpty(this.phrase);
  }

  get phrase() {
    return this._phrase;
  }

  set phrase(value) {
    const trimmedValue = value.trim();
    const priorPhrase = this._phrase;

    if (this._phrase === trimmedValue) { return; }

    this._phrase = trimmedValue;
    if (this.$input[0].value !== value) {
      this.$input[0].value = value;
    }

    this.$input.toggleClass('has-value', !Object.isEmpty(this._phrase));

    if (priorPhrase === undefined) { return; }

    if (this._phrase) { // it is undefined in constructor
      this.searchEngine.search(this._phrase);
      //   this._activate();
      //   this.debouncedSearch(this._phrase);
    } else {
      this.searchEngine.cancel();
      this._renderModes();
    }
  }

  get inputSearchPhrase() {
    return this.$input.val().trim();
  }

  // private functions
  _activate() {
    if (this.isActive) { return; }

    this.isActive = true;
    $('.l-top_menu-v2').addClass('is-global_search');

    this._renderModes();
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

  _renderModes() {
    this.$content.html(
      JST['search/options']({
        currentMode: this.currentMode,
        hasCollection: this.hasCollection
      })
    );
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

    const $node = $(node);
    $node.addClass('active');

    if (doScroll) {
      this._scrollToItem($node);
    }
  }

  _deselectItems() {
    this.$content.find(ITEM_SELECTOR).removeClass('active');
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
      this.$content.find(ITEM_SELECTOR).first()[0];

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
